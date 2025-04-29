// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DeployCrowdRaise} from "../../script/DeployCrowdRaise.s.sol";
import {CrowdRaise} from "../../src/CrowdRaise.sol";
import {Test, console} from "forge-std/Test.sol";

contract CrowdRaiseTest is Test {
    CrowdRaise crowdRaise;

    uint256 public constant SEND_VALUE = 0.01 ether;
    uint256 public constant STARTING_BALANCE = 100 ether;

    uint160 public constant USER_NUMBER = 46;
    address public constant USER = address(USER_NUMBER);

    function setUp() external {
        DeployCrowdRaise deployCrowdRaise = new DeployCrowdRaise();
        crowdRaise = deployCrowdRaise.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumFundIsFiveUsd() public view {
        assertEq(crowdRaise.MINIMUM_USD(), 5e18);
    }
}
