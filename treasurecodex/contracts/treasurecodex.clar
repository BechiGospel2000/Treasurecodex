;; Crypto Quest
;; A blockchain-based quest with progressive puzzles and rewards

;; Constants
(define-constant UNAUTHORIZED-ERROR (err u1))
(define-constant INACTIVE-QUEST-ERROR (err u2))
(define-constant INVALID-STAGE-ERROR (err u3))
(define-constant ALREADY-COMPLETED-ERROR (err u4))
(define-constant INCORRECT-SOLUTION-ERROR (err u5))
(define-constant TIME-RESTRICTED-ERROR (err u6))
(define-constant INSUFFICIENT-FUNDS-ERROR (err u7))

;; Data Variables
(define-data-var quest-manager principal tx-sender)
(define-data-var quest-status bool false)
(define-data-var active-phase uint u0)
(define-data-var participation-cost uint u1000000) ;; 1 STX
(define-data-var cumulative-reward uint u0)

;; Quest Phase Structure
(define-map quest-phases
    uint
    {
        hint: (string-utf8 256),
        solution-verification: (buff 32), ;; SHA256 hash of the solution
        unlock-block: uint,
        phase-reward: uint,
        phase-completed: bool
    }
)

;; Explorer Progress Tracking
(define-map explorer-progress
    principal
    {
        current-phase: uint,
        completed-phases: (list 20 uint),
        last-challenge-attempt: uint,
        total-phases-solved: uint
    }
)

;; Explorer Solutions History
(define-map phase-solution-attempts
    {phase: uint, explorer: principal}
    {
        attempt-count: uint,
        completion-block: (optional uint)
    }
)

;; Events
(define-map phase-champions
    uint
    (list 10 {explorer: principal, completion-block: uint})
)

;; Authorization
(define-private (is-manager)
    (is-eq tx-sender (var-get quest-manager)))

;; Quest Management Functions
(define-public (initialize-quest)
    (begin
        (asserts! (is-manager) UNAUTHORIZED-ERROR)
        (var-set quest-status true)
        (var-set active-phase u0)
        (var-set cumulative-reward u0)
        (ok true)))

(define-public (add-quest-phase
    (phase-id uint)
    (hint (string-utf8 256))
    (solution-verification (buff 32))
    (unlock-block uint)
    (phase-reward uint))
    (begin
        (asserts! (is-manager) UNAUTHORIZED-ERROR)
        (map-set quest-phases phase-id
            {
                hint: hint,
                solution-verification: solution-verification,
                unlock-block: unlock-block,
                phase-reward: phase-reward,
                phase-completed: false
            })
        (var-set cumulative-reward (+ (var-get cumulative-reward) phase-reward))
        (ok true)))

;; Explorer Registration
(define-public (register-explorer)
    (begin
        (asserts! (var-get quest-status) INACTIVE-QUEST-ERROR)
        ;; Require entry fee
        (try! (stx-transfer? (var-get participation-cost) tx-sender (var-get quest-manager)))
        
        (map-set explorer-progress tx-sender
            {
                current-phase: u0,
                completed-phases: (list),
                last-challenge-attempt: u0,
                total-phases-solved: u0
            })
        (ok true)))

;; Gameplay Functions
(define-public (submit-solution
    (phase-id uint)
    (solution (buff 32)))
    (let (
        (phase (unwrap! (map-get? quest-phases phase-id) INVALID-STAGE-ERROR))
        (explorer (unwrap! (map-get? explorer-progress tx-sender) INVALID-STAGE-ERROR))
        )
        ;; Check phase availability
        (asserts! (var-get quest-status) INACTIVE-QUEST-ERROR)
        (asserts! (>= block-height (get unlock-block phase)) TIME-RESTRICTED-ERROR)
        (asserts! (not (get phase-completed phase)) ALREADY-COMPLETED-ERROR)
        
        ;; Verify solution - directly compare the hashes
        (if (is-eq solution (get solution-verification phase))
            (begin
                ;; Update phase status
                (map-set quest-phases phase-id
                    (merge phase {phase-completed: true}))
                
                ;; Update explorer progress
                (map-set explorer-progress tx-sender
                    (merge explorer {
                        current-phase: (+ phase-id u1),
                        completed-phases: (unwrap! (as-max-len? 
                            (append (get completed-phases explorer) phase-id) u20)
                            INVALID-STAGE-ERROR),
                        total-phases-solved: (+ (get total-phases-solved explorer) u1)
                    }))
                
                ;; Record solution
                (map-set phase-solution-attempts
                    {phase: phase-id, explorer: tx-sender}
                    {
                        attempt-count: u1,
                        completion-block: (some block-height)
                    })
                
                ;; Award reward
                (try! (stx-transfer? (get phase-reward phase) (var-get quest-manager) tx-sender))
                
                ;; Record champion
                (match (map-get? phase-champions phase-id)
                    champions (map-set phase-champions phase-id
                        (unwrap! (as-max-len?
                            (append champions {explorer: tx-sender, completion-block: block-height})
                            u10)
                            INVALID-STAGE-ERROR))
                    (map-set phase-champions phase-id
                        (list {explorer: tx-sender, completion-block: block-height})))
                
                (ok true))
            INCORRECT-SOLUTION-ERROR)))

;; Read-only functions
(define-read-only (get-current-hint (phase-id uint))
    (match (map-get? quest-phases phase-id)
        phase (if (>= block-height (get unlock-block phase))
            (ok (get hint phase))
            TIME-RESTRICTED-ERROR)
        INVALID-STAGE-ERROR))

(define-read-only (get-explorer-status (explorer principal))
    (map-get? explorer-progress explorer))

(define-read-only (get-phase-champions (phase-id uint))
    (map-get? phase-champions phase-id))

(define-read-only (get-quest-stats)
    {
        active: (var-get quest-status),
        current-phase: (var-get active-phase),
        total-reward-pool: (var-get cumulative-reward),
        entry-fee: (var-get participation-cost)
    })