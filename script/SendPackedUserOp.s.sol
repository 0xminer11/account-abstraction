// SPDX License Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;
    function run() public {}


    function generatePackedUserOp(bytes memory callData,HelperConfig.NetworkConfig memory config) public returns (PackedUserOperation memory) {
        uint256 nonce = vm.getNonce(config.account);
        PackedUserOperation memory UserOp = _generateUnsignedPackedUserOp(callData, config.account, nonce);
        IEntryPoint entryPoint = IEntryPoint(config.entryPoint);
        bytes32 messageHash = entryPoint.getUserOpHash(UserOp);
        bytes32 signedMessageHash = messageHash.toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s)=vm.sign(config.account, signedMessageHash);
        UserOp.signature = abi.encodePacked(v, r, s);
        return UserOp;
    }


    function _generateUnsignedPackedUserOp(bytes memory callData, address sender, uint256 nonce) public returns (PackedUserOperation memory) {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = 16777216;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = 256;
        return PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: hex"",
            callData: callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        });
    }

}