// SPDX License Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";

contract HelperConfig is Script   {
    error  HelperConfig_InvalidChainId();


    struct NetworkConfig{
        address entryPoint;
        address usdc;
        address account;
    }
    uint256 constant LOCAL_NETWORK_CAHIN_ID = 1;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant AMOY_CHAIN_ID = 80002;
    address constant BURNER_WALLET = 0xc92AF7f5D63bE657c55A5519936d40F3E65070F2;
    address constant ANVIL_DEFAULT_SENDER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    NetworkConfig public localnetworkConfig;

    mapping(uint256 => NetworkConfig) public networkConfigs; 

    constructor() {
       networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getETHSepoliaConfig();
       networkConfigs[AMOY_CHAIN_ID] = getAmoyConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getETHSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            usdc :0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0,
            account: BURNER_WALLET});
    }

    function getAmoyConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            usdc :0x41E94Eb019C0762f9Bfcf9Fb1E58725BfB0e7582,
            account: 0x47bEe4e8D1843F456C20b8B9e38f308F97f170E0});
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == LOCAL_NETWORK_CAHIN_ID) {
            return getOrCereateAnvilconfig();
        }else if(networkConfigs[chainId].account != address(0)){
            return networkConfigs[chainId];
        }else{
            revert HelperConfig_InvalidChainId();
        }
    }

    function getOrCereateAnvilconfig() public returns (NetworkConfig memory) {
        if (localnetworkConfig.account != address(0)) {
            return localnetworkConfig;
        }
        vm.startBroadcast();
        EntryPoint entryPoint = new EntryPoint();
        vm.stopBroadcast();

        return NetworkConfig({
            entryPoint: address(entryPoint),
            usdc:0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0,
            account: ANVIL_DEFAULT_SENDER
        });

    }
// 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789

}