// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {CrowdRaise} from "../src/CrowdRaise.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployCrowdRaise is Script {
    uint256 USD_GOAL = 1000e18;
    uint256 DAYS = 7;

    function run() external returns (CrowdRaise) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        uint256 usdGoalAmount = 1000e18;
        uint256 deadlineInDays = 7;

        vm.startBroadcast();
        CrowdRaise crowdRaise = new CrowdRaise(ethUsdPriceFeed, usdGoalAmount, deadlineInDays);
        vm.stopBroadcast();
        return crowdRaise;
    }
}
