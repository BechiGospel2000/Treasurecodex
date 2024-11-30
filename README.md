# **Treasurecodex**  
*A Blockchain-Based Crypto Scavenger Hunt Smart Contract*  

## **Overview**  
Treasurecodex is a decentralized smart contract built in Clarity that enables a **blockchain-based scavenger hunt**. Players solve progressively challenging puzzles to unlock rewards in STX tokens. Each puzzle (or stage) has a clue, a solution, and a prize. Players compete to solve stages, with prizes distributed automatically upon successful completion.  

### **Features**  
- **Admin-Managed Hunts**: The admin initializes and manages the scavenger hunt by adding stages with clues, solutions, unlock times, and prizes.  
- **Player Registration**: Players register by paying an entry fee to participate in the hunt.  
- **Progressive Puzzles**: Stages unlock sequentially, with each stage requiring a correct solution to proceed to the next.  
- **Prize Distribution**: Winners are awarded STX tokens for each solved stage, and a leaderboard is maintained for each stage.  
- **Time-Locked Clues**: Clues for each stage are only revealed after a specified block height.

---

## **Contract Flow**  

1. **Initialization**:  
   The admin initializes the hunt using the `initialize-hunt` function to set the contract to an active state and reset the current stage to zero.

2. **Adding Stages**:  
   The admin adds new stages with clues, hashed solutions, unlock heights, and prize amounts using the `add-stage` function.

3. **Player Registration**:  
   Players register for the hunt by calling the `register-player` function and paying the entry fee.

4. **Submitting Solutions**:  
   Players submit their solution to a stage using the `submit-solution` function. If correct, they:
   - Unlock the next stage.
   - Receive the prize associated with the solved stage.
   - Have their solution recorded on the leaderboard.

5. **Leaderboard and Player Progress**:  
   Players can view their progress and solved stages, while spectators can view the leaderboard for each stage.

---

## **Key Components**  

### **Data Structures**  

- **`hunt-stages`**:  
  A map that stores information about each stage, including:  
  - `clue`: The puzzle or hint for the stage.  
  - `encrypted-solution`: A hash of the correct solution.  
  - `unlock-height`: The block height after which the stage becomes available.  
  - `prize`: The reward for solving the stage.  
  - `solved`: A boolean indicating whether the stage has been solved.

- **`player-progress`**:  
  Tracks player progress, including:  
  - `current-stage`: The current stage the player is attempting to solve.  
  - `solved-stages`: A list of all stages solved by the player.  
  - `last-attempt`: The block height of the player's last solution attempt.  
  - `total-solved`: The total number of stages solved by the player.

- **`stage-solutions`**:  
  Records solution attempts and successful solutions for each stage by each player.

- **`stage-winners`**:  
  Maintains a leaderboard of the top 10 players who solved each stage, along with the block height at which they solved it.

---

## **Public Functions**  

### **1. `initialize-hunt`**  
Initializes the hunt and activates it.  
- **Access**: Admin only.  
- **Returns**: `true` if successful.

---

### **2. `add-stage`**  
Adds a new stage to the hunt.  
- **Parameters**:  
  - `stage-id`: The ID of the stage.  
  - `clue`: The clue for the stage.  
  - `solution-hash`: The SHA256 hash of the correct solution.  
  - `unlock-height`: The block height at which the stage becomes available.  
  - `prize`: The prize for solving the stage.  
- **Access**: Admin only.  
- **Returns**: `true` if successful.

---

### **3. `register-player`**  
Registers a player for the hunt and deducts the entry fee.  
- **Access**: Public.  
- **Returns**: `true` if successful.

---

### **4. `submit-solution`**  
Allows a player to submit a solution to a stage.  
- **Parameters**:  
  - `stage-id`: The ID of the stage being solved.  
  - `solution-hash`: The hash of the submitted solution.  
- **Access**: Public.  
- **Returns**: `true` if the solution is correct, error otherwise.

---

### **Read-Only Functions**  

1. **`get-current-clue`**:  
   Retrieves the clue for a specific stage if it is unlocked.  
   - **Parameters**:  
     - `stage-id`: The ID of the stage.  
   - **Returns**: The clue or an error if the stage is locked.

2. **`get-player-status`**:  
   Retrieves the progress of a player.  
   - **Parameters**:  
     - `player`: The player's principal address.  
   - **Returns**: The player’s progress data.

3. **`get-stage-winners`**:  
   Retrieves the top 10 winners of a stage.  
   - **Parameters**:  
     - `stage-id`: The ID of the stage.  
   - **Returns**: A list of winners and the block height they solved the stage.

4. **`get-hunt-stats`**:  
   Provides general statistics about the hunt.  
   - **Returns**:  
     - `active`: Whether the hunt is active.  
     - `current-stage`: The current stage of the hunt.  
     - `total-prize-pool`: The total prize pool for the hunt.  
     - `entry-fee`: The fee required to register.

---

## **Errors**  

| **Error Code**     | **Description**                           |
|--------------------|-------------------------------------------|
| `ERR-NOT-AUTHORIZED` | Action attempted by a non-admin user.     |
| `ERR-HUNT-NOT-ACTIVE`| Hunt is not currently active.            |
| `ERR-INVALID-STAGE`  | Stage ID is invalid.                    |
| `ERR-ALREADY-SOLVED` | Stage has already been solved.           |
| `ERR-WRONG-SOLUTION` | Incorrect solution submitted.            |
| `ERR-TIME-LOCKED`    | Stage is not yet unlocked.               |
| `ERR-INSUFFICIENT-PAYMENT` | Entry fee not sufficient.           |

---

## **How to Deploy and Interact**  

1. **Deploy the Smart Contract**:  
   Use the Stacks CLI or a smart contract deployment tool to deploy the `Treasurecodex` contract.

2. **Initialize the Hunt**:  
   Call the `initialize-hunt` function to activate the hunt.

3. **Add Stages**:  
   Add stages with clues and rewards using the `add-stage` function.

4. **Register Players**:  
   Players can register for the hunt by paying the entry fee through the `register-player` function.

5. **Submit Solutions**:  
   Players solve the stages by submitting hashed solutions through the `submit-solution` function.

---

## **Future Enhancements**  
- **Multi-Chain Support**: Integration with multiple blockchain networks.  
- **NFT Rewards**: Addition of NFT collectibles for stage completion.  
- **Dynamic Puzzles**: Puzzles that adapt based on player behavior.  

---

## **License**  
This project is open-source and available under the MIT License.  

Enjoy the hunt and may the best treasure hunter win! 🚀