// SPDX-License-Identifier: Open Source With Commercial Restrictions
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library PxHelper {
    uint256 private constant _maxPercentage = 100;
    using SafeMath for uint256;

    function calculatePercentageDifference(uint256 oldValue, uint256 newValue) public pure returns (uint256) {
        uint256 difference = oldValue.sub(newValue);
        uint256 percentageDifference = (difference.mul(100)).div(oldValue);
        return _maxPercentage.sub(percentageDifference);
    }
}