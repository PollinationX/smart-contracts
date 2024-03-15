// SPDX-License-Identifier: Open Source With Commercial Restrictions
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./PXUtils.sol";

library PXStorage {
    using SafeMath for uint256;
    using Strings for uint256;

    struct StoragePackage {
        uint256 id;
        string name;
        uint256 price;
        uint256 size;
        uint256 sizeInBytes;
        string storageUnit;
        uint256 bandwidthLimit;
        uint256 active;
    }
    struct BandwidthPackage {
        uint256 id;
        string name;
        uint256 price;
        uint256 bandwidth;
        uint256 active;
    }

    struct ExtraContent {
        string metadata;
        uint256 active;
    }

    struct Storage {
        string name;
        uint256 usage;
        uint256 usagePercentage;
        uint256 size;
        uint256 sizeInBytes;
        string storageUnit;
        uint256 buyTimestamp;
        uint256 lastUpdateTimestamp;
        uint256 bandwidth;
        mapping(bytes32 => ExtraContent) extraContent;
    }

    struct FreePackage {
        uint256 alreadyMinted;
    }

    function getAllPackages(uint256[] memory packageIds, mapping(uint256 => StoragePackage) storage pxStoragePackage) internal view returns (StoragePackage[] memory) {
        StoragePackage[] memory result = new StoragePackage[](packageIds.length);
        for (uint256 i = 0; i < packageIds.length; i++) {
            result[i] = pxStoragePackage[packageIds[i]];
        }
        return result;
    }
    function canUpload(
        mapping(uint256 => Storage) storage pxStorage,
        uint256 tokenId,
        uint256 newUsage
    ) internal view returns (bool) {
        if (
            (pxStorage[tokenId].usage.add(newUsage)) >
            pxStorage[tokenId].sizeInBytes
        ) {
            return false;
        }
        return true;
    }
    function getTokenURI(
        mapping(uint256 => Storage) storage pxStorage,
        uint256 tokenId,
        uint256 currentUsage,
        uint256 storageSize,
        string memory storageUnit
    ) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            '{"name": "PollinationX #',
            tokenId.toString(),
            '","description": "Decentralized Storage On Demand","image": "',
            PXUtils.getProgressImage(storageUnit, pxStorage[tokenId].size.toString(), pxStorage[tokenId].usagePercentage.toString()),
            '","attributes": [{"display_type": "boost_percentage","trait_type": "Usage","value": ',
            currentUsage.toString(),
            '},{"trait_type": "Capacity","value": "',
            storageSize.toString(),
            storageUnit,
            '"},{"trait_type": "Bandwidth","value": "',
            pxStorage[tokenId].bandwidth.toString(),
            '"}]}'
        );
        return
            string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
}
