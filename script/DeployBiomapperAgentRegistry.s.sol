// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {BiomapperAgentRegistry} from "../src/BiomapperAgentRegistry.sol";

contract DeployBiomapperAgentRegistry is Script {
    function run() external {
        address bridgedBiomapper = vm.envAddress("BRIDGED_BIOMAPPER");

        vm.startBroadcast();

        BiomapperAgentRegistry registry = new BiomapperAgentRegistry(bridgedBiomapper);

        vm.stopBroadcast();

        console.log("BiomapperAgentRegistry deployed at:", address(registry));
    }
}
