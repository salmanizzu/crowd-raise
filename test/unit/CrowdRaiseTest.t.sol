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

    modifier funded() {
        vm.prank(USER);
        crowdRaise.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        DeployCrowdRaise deployCrowdRaise = new DeployCrowdRaise();
        crowdRaise = deployCrowdRaise.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    /* ==================================================================================
     *     FUND TEST
     * ================================================================================== */

    function testOwnerIsMsgSender() public view {
        assertEq(crowdRaise.getOwner(), msg.sender);
    }

    function testMinimumFundIsFiveUsd() public view {
        assertEq(crowdRaise.MINIMUM_USD(), 5e18);
    }

    function testCantFundLessThanFiveUsd() public {
        vm.expectRevert();
        crowdRaise.fund();
    }

    function testCantFundAfterDeadline() public {
        vm.warp(crowdRaise.getDeadline() + 1);
        vm.prank(USER);
        vm.expectRevert();
        crowdRaise.fund();
    }

    function testFundUpdatesFundAmount() public funded {
        uint256 fundAmount = crowdRaise.getAddressToAmountFunded(USER);
        assertEq(fundAmount, SEND_VALUE);
    }

    function testFundUpdatesFunderArray() public funded {
        address funder = crowdRaise.getFunder(0);
        assertEq(funder, USER);
    }

    function testMultipleFundsUpdateTotalFund() public {
        uint160 numberOfFunders = 5;
        uint160 startingFunderIndex = 1;
        uint256 fundAmount = 0;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            console.log(fundAmount, crowdRaise.getTotalFund());
            hoax(address(i), STARTING_BALANCE);
            crowdRaise.fund{value: SEND_VALUE}();
            fundAmount += SEND_VALUE;
        }
        assertEq(fundAmount, crowdRaise.getTotalFund());
    }

    /* ==================================================================================
     *     WITHDRAW TEST
     * ================================================================================== */

    function onlyOwnerCanWithdraw() public {}
}
