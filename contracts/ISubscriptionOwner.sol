// SPDX-License-Identifier: Open Source With Commercial Restrictions

pragma solidity ^0.8.10;

interface ISubscriptionOwner {
    function getSubscriptionOwner() external view returns (address);
}