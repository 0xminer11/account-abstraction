// SPDX License Identifier: MIT

pragma solidity 0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_SUCCESS,SIG_VALIDATION_FAILED} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount,Ownable {

    //////////////////////////////////////////////
    ////            Error messages           ////
    //////////////////////////////////////////////

    error NotFromEntryPoint();
    error NotFromEntryPointOrOwner();
    error MinimalAccount_CallFailed(bytes);
    IEntryPoint private immutable i_entryPoint;

    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint= IEntryPoint(entryPoint);
    }

    // Fallback function to receive ether
    receive() external payable {}
    //////////////////////////////////////////////
    ////              Modifiers               ////
    //////////////////////////////////////////////
    modifier onlyEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert NotFromEntryPoint();
        }
        _;
    }

    modifier onlyEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) || msg.sender != owner()) {
            revert NotFromEntryPointOrOwner();
        }
        _;
    }

    //////////////////////////////////////////////
    ////          External Functions          ////
    //////////////////////////////////////////////
    /**
     * 
     * Execute a call to a contract
     * @param destination : The address of the contract to call
     * @param value      : The amount of ether to send
     * @param functionData : The data of the function to call
     */
    function execute(address destination,uint256 value,bytes calldata functionData) external onlyEntryPoint {
        (bool success,bytes memory results) = destination.call{value: value}(functionData);
        if (!success) {
            revert MinimalAccount_CallFailed(results);
        }
        require(success, "MinimalAccount: execution failed");
    } 

    // Get the entry point address 
    /**
     * Get the entry point address
     * @return address : The address of the entry point
     */
    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }

    
    // Validate user's signature and nonce
    // the entryPoint will make the call to the recipient only if this validation call returns successfully.
    // signature failure should be reported by returning SIG_VALIDATION_FAILED (1).
    /**
     * 
     * @param userOp : The operation that is about to be executed.
     * @param userOpHash : Hash of the user's request data. can be used as the basis for signature.
     * @param missingAccountFunds : Missing funds on the account's deposit in the entrypoint.
     */
    function validateUserOp(PackedUserOperation calldata userOp,bytes32 userOpHash,uint256 missingAccountFunds)
    external  
    onlyEntryPoint
    returns (uint256 validationData)
    {
        // This is a minimal implementation of the validateUserOp function
        // If its the the MinimalAccount Owner, then the signature is valid
        validationData = _validateSignature(userOp, userOpHash);
        _payPrefund(missingAccountFunds);
    }

    //////////////////////////////////////////////
    ////          Internal Functions          ////
    //////////////////////////////////////////////

    // EIP 191 version of the signed message hash.
    /**
     * 
     * Validate the user's signature
     * @param userOp : The operation that is about to be executed.
     * @param userOpHash : Hash of the user's request data. can be used as the basis for signature.
     */
    function _validateSignature(PackedUserOperation calldata userOp,bytes32 userOpHash) internal view returns(uint256 validationData) {
        // This is a minimal implementation of the validateSignature function
        // If its the the MinimalAccount Owner, then the signature is valid

        // convert the userOpHash to an eth signed message hash
        bytes32 ethSignedmessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        // Recover the signer address from the signature
        address signer = ECDSA.recover(ethSignedmessageHash, userOp.signature);
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        } else {
            return SIG_VALIDATION_SUCCESS;
        }
        
    }

    // Pay the prefund to the entrypoint
    /**
     * 
     * Pay the prefund to the entrypoint
     * @param missingAccountFunds : Missing funds on the account's deposit in the entrypoint.
     */
    function _payPrefund(uint256 missingAccountFunds) internal {
        // This is a minimal implementation of the payPrefund function
        // If there are missing funds, then transfer the missing funds to the entrypoint
       if(missingAccountFunds != 0) {
           (bool success, ) = payable(msg.sender).call{value: missingAccountFunds,gas:type(uint256).max}("");
           (success);
       }
    }
}