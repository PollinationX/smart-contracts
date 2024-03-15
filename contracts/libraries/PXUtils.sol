// SPDX-License-Identifier: Open Source With Commercial Restrictions
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Base64.sol";

library PXUtils {
    // Function to calculate percentage difference
    function calculatePercentageDifference(uint256 oldValue, uint256 newValue) internal pure returns (uint256) {
        uint256 difference = oldValue > newValue ? oldValue - newValue : newValue - oldValue;
        if (oldValue == 0) {
            return 0;
        }
        uint256 percentageDifference = (difference * 100) / oldValue;
        return 100 - percentageDifference;
    }
    function getProgressImage(
        string memory storageUnit,
        string memory size,
        string memory usagePercentage
    ) external pure returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 250 350"><defs><style>.cls-1, .cls-3, .cls-4 {fill: #fff;font-size: 21px;}.cls-5 {fill: #fab432;}.cls-6 {fill: #222;}.cls-7 {letter-spacing: -.01em;}.cls-8 {letter-spacing: -.01em;}.cls-9, .cls-10 {letter-spacing: -.03em;}.cls-11 {letter-spacing: 0em;}.cls-12 {letter-spacing: 0em;}.cls-13 {fill: #878989;font-size: 18px;}</style></defs><rect class="cls-6" width="250" height="350"/><path class="cls-5" d="m125.88,125.5l-37.48,21.66v43.52l34.37,19.83,2.74,8.16h.8l2.69-8.17,34.32-19.83v-43.52l-37.44-21.66Zm15.42,72.71l-15.42,8.9-15.45-8.92v-8.59s15.45,8.92,15.45,8.92l15.45-8.92-.03,8.6Zm-15.42-4.89l-15.45-8.92v-8.59s15.45,8.92,15.45,8.92l15.42-8.9.03,8.57-15.45,8.92Zm15.42-22.69l-15.42,8.9-15.45-8.92v-8.59l15.45,8.92,15.42-8.9v8.59Zm-15.42-4.89l-12.99-7.5,12.99-7.5,12.99,7.5-12.99,7.5Zm-4.82-17.41l-12.87,7.43-12.87-7.43,12.87-7.43,12.87,7.43Zm22.5,7.42l-12.85-7.42,12.86-7.42,12.85,7.42-12.86,7.42Zm-4.57-17.45l-13.1,7.57-13.1-7.57,13.1-7.57,13.1,7.57Zm-46.11,13.77l13.06,7.54v8.46l-13.06-7.54v-8.46Zm0,13.62l13.06,7.54v8.61l-13.06-7.54v-8.61Zm0,13.77l13.06,7.54v8.63l-13.06-7.54v-8.63Zm65.98,8.63l-13.03,7.52v-8.62h0s13.03-7.53,13.03-7.53v8.63Zm0-13.79l-13.03,7.52v-8.61l13.03-7.52v8.61Zm-13.03-6.25v-8.46l13.03-7.52v8.46l-13.03,7.52Z"/><text class="cls-3" transform="translate(88.79 247.36)"><tspan class="cls-11" x="0" y="0">US</tspan><tspan class="cls-8" x="29.36" y="0">A</tspan><tspan class="cls-11" x="44.88" y="0">GE</tspan></text><text class="cls-3" transform="translate(45.16 109.16)"><tspan class="cls-12" x="0" y="0">S</tspan><tspan class="cls-10" x="13.4" y="0">T</tspan><tspan class="cls-12" x="26.21" y="0">OR</tspan><tspan class="cls-7" x="57.71" y="0">A</tspan><tspan class="cls-11" x="73.23" y="0">GE SIZE</tspan><tspan class="cls-2" x="155.54" y="0"> </tspan></text><text class="cls-9" transform="translate(104.4 85.2)"><tspan class="cls-13" x="0" y="0">',
            size,
            storageUnit,
            '</tspan><tspan class="cls-4" x="37.08" y="0"> </tspan></text><text class="cls-9" transform="translate(106.11 271.46)"><tspan class="cls-13" x="0" y="0">',
            usagePercentage,
            '%</tspan><tspan class="cls-1" x="33.66" y="0"> </tspan></text></svg>'
        );

        return
            string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }


}
