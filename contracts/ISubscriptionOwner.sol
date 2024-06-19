// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface ISubscriptionOwner {
    function getSubscriptionOwner() external view returns (address);
}