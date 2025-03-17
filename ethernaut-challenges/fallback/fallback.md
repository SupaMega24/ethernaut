# Challenge 1 - Fallback  

## Understanding Fallback Functions  

In Solidity, a contract can have a special function called a **fallback function**, which is executed when:  
1. The contract receives ether without any data.  
2. The contract is called with an unrecognized function selector.  

Fallback functions can be defined as either `fallback()` or `receive()`:  

- **`receive()`**: A special type of fallback function that only executes when ether is sent to the contract **without any calldata**.  
- **`fallback()`**: Executes when ether is sent with calldata **or** when a non-existent function is called.  

If neither `receive()` nor `fallback()` is defined, the contract rejects direct ether transfers.  

## Breaking Down the Exploit  

The **Fallback** contract in this challenge has two key vulnerabilities:  

1. **The receive function grants ownership**  
   - The contract has a `receive()` function that transfers ownership if the sender has previously contributed any ether.  
   - This allows an attacker to first make a tiny contribution, then send a direct ether transfer to trigger `receive()`, effectively taking control.  

2. **The withdraw function lets the owner drain funds**  
   - Once an attacker becomes the owner, they can call `withdraw()`, which transfers the entire contract balance to them.  

### Step-by-Step Exploitation  

#### Step 1: Make a Small Contribution  

Before an ether transfer can trigger `receive()`, the attacker must have a **nonzero contribution**. This is done by calling `contribute()` with a small amount of ether:  

```javascript
await contract.contribute({value: toWei('0.0009')})
```  

This ensures the `receive()` function condition will be met.  

#### Step 2: Send Ether to the Contract  

Next, send a direct ether transfer to trigger `receive()`:  

```javascript
await web3.eth.sendTransaction({to: contract.address, from: player, value: toWei('0.0001')})
```  

Since the sender has contributed before, `receive()` executes and transfers ownership to them.  

#### Step 3: Verify Ownership  

To confirm ownership, check the contract’s `owner` variable:  

```javascript
await contract.owner()
```  

If the player's address matches, ownership was successfully taken over.  

#### Step 4: Withdraw All Funds  

As the new owner, the attacker can now drain the contract:  

```javascript
await contract.withdraw()
```  

Since `withdraw()` is restricted to the owner, this would have been impossible before taking ownership.  

---

## Key Takeaways  

- **Fallback functions can be dangerous**: If a fallback function modifies contract state (such as assigning ownership), it can lead to unintended privilege escalation.  
- **Check access control in smart contracts**: Ownership transfers should only happen through explicit, well-validated function calls.  
- **Don’t rely on contributions for security**: The `receive()` function mistakenly assumes that only a legitimate contributor would send ether, allowing an attacker to bypass expected ownership conditions.  
- **Use OpenZeppelin’s Ownable**: Implementing `Ownable` ensures only authorized addresses can become owners, preventing unintended takeovers.  

### Fixing the Vulnerability  

To fix this issue, **remove the ownership transfer from `receive()`** and restrict it to an explicitly authorized function:  

```solidity
contract SecureFallback {
    address public owner;
    mapping(address => uint256) public contributions;

    constructor() {
        owner = msg.sender;
    }

    function contribute() public payable {
        contributions[msg.sender] += msg.value;
    }

    function withdraw() public {
        require(msg.sender == owner, "Not the owner");
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        require(msg.value > 0, "Send ether to contribute");
    }
}
```  

This ensures:  
✅ Ownership cannot be transferred arbitrarily.  
✅ The fallback function only allows receiving ether without changing contract state.  

