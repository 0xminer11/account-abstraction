// SPDX License Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script   {
    error  HelperConfig_InvalidChainId();


    struct NetworkConfig{
        address entryPoint;
        address account;
    }
    uint256 constant LOCAL_NETWORK_CAHIN_ID = 1;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    address constant BURNER_WALLET = 0xc92AF7f5D63bE657c55A5519936d40F3E65070F2;

    NetworkConfig public localnetworkConfig;

    mapping(uint256 => NetworkConfig) public networkConfigs; 

    constructor() {
       networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getETHSepoliaConfig();
    }

    function getConfig() public view returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getETHSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            account: BURNER_WALLET});
    }

    function getConfigByChainId(uint256 chainId) public view returns (NetworkConfig memory) {
        if (chainId == LOCAL_NETWORK_CAHIN_ID) {
            return getOrCereateAnvilconfig();
        }else if(networkConfigs[chainId].account != address(0)){
            return networkConfigs[chainId];
        }else{
            revert HelperConfig_InvalidChainId();
        }
    }

    function getOrCereateAnvilconfig() public view returns (NetworkConfig memory) {
        if (localnetworkConfig.account != address(0)) {
            return localnetworkConfig;
        }
        // return config;
    }
// 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789

}