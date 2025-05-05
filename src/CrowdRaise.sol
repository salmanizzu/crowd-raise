// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error CrowdRaise__NotOwner();
error CrowdRaise__GoalNotReached();

contract CrowdRaise {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;

    address[] private s_funders;
    uint256 private s_totalFunded;
    address private immutable i_owner;
    uint256 private immutable i_usdGoal;
    uint256 private immutable i_deadline;
    AggregatorV3Interface private s_priceFeed;

    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    uint256 public constant SECOND_TO_DAY = 24 * 60 * 60;

    event Funded(address indexed funder, uint256 amount);
    event Withdrawn(address indexed recipient, uint256 amount);

    constructor(address priceFeed, uint256 goalUsdAmount, uint256 durationInDays) {
        require(goalUsdAmount >= 100 * 10 ** 18);
        require(goalUsdAmount <= 1_000_000 * 10 ** 18);
        i_owner = msg.sender;
        i_usdGoal = goalUsdAmount;
        i_deadline = block.timestamp + (durationInDays * SECOND_TO_DAY);
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert CrowdRaise__NotOwner();
        _;
    }

    function fund() public payable {
        require(block.timestamp <= i_deadline, "Deadline passed!");
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_totalFunded += msg.value;
        s_funders.push(msg.sender);

        emit Funded(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        require(block.timestamp > i_deadline, "Deadline not met!");
        if (s_totalFunded <= i_usdGoal) revert CrowdRaise__GoalNotReached();

        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);

        emit Withdrawn(i_owner, address(this).balance);
    }

    /* ==================================================================================
     *     GETTER FUNCTION
     * ================================================================================== */

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getTotalFund() external view returns (uint256) {
        return s_totalFunded;
    }

    function getDeadline() external view returns (uint256) {
        return i_deadline;
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }
}
