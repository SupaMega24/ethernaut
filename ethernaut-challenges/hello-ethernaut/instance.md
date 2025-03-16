

# Challenge 0 - Hello Ethernaut  

## Summary  

This challenge serves as an introduction to Ethernaut, requiring players to navigate the contract using the developer console in Chrome. The goal is to retrieve the `password` variable and use it to authenticate successfully.  

## Steps to Solve  

1. **Exploring the Contract**  
   - The contract contains multiple `info` functions that provide hints on the next function to call.  
   - The `password` variable is declared as `public`, meaning it can be accessed directly.  

2. **Using the Developer Console**  
   - Started by calling `await contract.info()` in the browser console.  
   - Followed the hints provided by each function:  
     - `info1()` hinted at calling `info2("hello")`.  
     - `info2("hello")` pointed to `infoNum`, which contained `42`.  
     - `info42()` directed to `theMethodName`, which was `method7123949()`.  
     - `method7123949()` revealed that the password needed to be submitted to `authenticate()`.  

3. **Retrieving the Password**  
   - Since `password` is a `public` variable, it was accessed directly using:  
     ```js
     await contract.password();
     ```  
   - The returned value was then passed as a parameter to the `authenticate` function:  
     ```js
     await contract.authenticate("retrieved_password");
     ```  
   - This successfully completed the challenge.  


## Key Takeaways  

- All storage variables in Solidity are accessible on-chain, regardless of their visibility (`public`, `private`, or `internal`). The `public` keyword only adds an auto-generated getter function.  
- Developer tools in browsers allow direct interaction with smart contracts.  
- Understanding function calls and storage visibility is critical in smart contract security.  

## Possible Solutions  

1. **Avoid Storing Sensitive Data On-Chain**  
   - Since all storage variables are accessible, even if declared `private`, sensitive data like passwords should never be stored on-chain. Instead, use **off-chain verification** (e.g., hashing the password off-chain and only storing a hash in the contract).  

2. **Use Keccak256 Hash Comparison (Better Design)**  
   - Instead of storing plain text, store only a hashed version (`keccak256` of the password). The user would then submit their password, which gets hashed and compared to the stored hash.  

   ```solidity
   // Instead of storing plain text
   bytes32 private passwordHash;

   constructor(string memory _password) {
       passwordHash = keccak256(abi.encodePacked(_password));
   }

   function authenticate(string memory passkey) public {
       require(keccak256(abi.encodePacked(passkey)) == passwordHash, "Wrong password");
       cleared = true;
   }
   ```

3. **Restrict Access to Debugging Functions**  
   - Functions that reveal information (`info()`, `info1()`, etc.) can be removed or restricted to only the owner or authorized users using `Ownable`.  
   - However, this only prevents function-based leaks, not the underlying storage issue.  

