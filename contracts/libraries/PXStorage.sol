// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./PXUtils.sol";

// PXStorage library for managing storage packages, bandwidth packages, and storage usage
library PXStorage {
    using SafeMath for uint256;
    using Strings for uint256;
    uint256 private constant _gbToBytes = 1073741824; // Conversion factor from GB to Bytes

    // Struct for defining storage packages
    struct StoragePackage {
        uint256 id; // Package ID
        string name; // Package name
        uint256 price; // Package price in wei
        uint256 size; // Size in GB
        uint256 sizeInBytes; // Size in bytes
        string storageUnit; // Storage unit (e.g., "GB")
        uint256 bandwidthLimit; // Bandwidth limit
        uint256 active; // Active status
    }
    // Struct for defining bandwidth packages
    struct BandwidthPackage {
        uint256 id; // Package ID
        string name; // Package name
        uint256 price; // Package price in wei
        uint256 bandwidth; // Bandwidth limit
        uint256 active; // Active status
    }

    // Struct for storing extra content associated with a storage
    struct ExtraContent {
        string metadata; // Metadata of the extra content
        uint256 active; // Active status
    }

    // Struct for defining the storage associated with a token
    struct Storage {
        string name; // Storage name
        uint256 usage; // Current usage in bytes
        uint256 usagePercentage; // Usage percentage
        uint256 size; // Size in GB
        uint256 sizeInBytes; // Size in bytes
        string storageUnit; // Storage unit (e.g., "GB")
        uint256 buyTimestamp; // Timestamp when the package was bought
        uint256 lastUpdateTimestamp; // Timestamp of the last update
        uint256 bandwidth; // Remaining bandwidth
        mapping(bytes32 => ExtraContent) extraContent; // Mapping of extra content
    }

    // Struct for managing free package information
    struct FreePackage {
        uint256 alreadyMinted; // Flag indicating if the free package has already been minted
    }

    // Function to add a new storage package
    function addNewPackage(
        mapping(uint256 => StoragePackage) storage pxStoragePackage,
        uint256[] storage packageIds,
        uint256 newPackageId,
        uint256 priceInWeiValue,
        uint256 sizeInGb,
        uint256 bandwidthLimit
    ) external {
        // Initialize the new storage package
        pxStoragePackage[newPackageId].id = newPackageId;
        pxStoragePackage[newPackageId].name = newPackageId.toString();
        pxStoragePackage[newPackageId].price = priceInWeiValue;
        pxStoragePackage[newPackageId].size = sizeInGb;
        pxStoragePackage[newPackageId].sizeInBytes = sizeInGb.mul(_gbToBytes);
        pxStoragePackage[newPackageId].storageUnit = "GB";
        pxStoragePackage[newPackageId].active = 1;
        pxStoragePackage[newPackageId].bandwidthLimit = bandwidthLimit;

        // Add the new package ID to the list of package IDs
        packageIds.push(newPackageId);
    }

    // Function to add a new bandwidth package
    function addNewBandwidthPackage(
        mapping(uint256 => BandwidthPackage) storage pxBandwidthPackage,
        uint256[] storage bandwidthPackageIds,
        uint256 newPackageId,
        uint256 priceInWeiValue,
        uint256 bandwidthLimit
    ) external {
        // Initialize the new bandwidth package
        pxBandwidthPackage[newPackageId].id = newPackageId;
        pxBandwidthPackage[newPackageId].name = bandwidthLimit.toString();
        pxBandwidthPackage[newPackageId].price = priceInWeiValue;
        pxBandwidthPackage[newPackageId].bandwidth = bandwidthLimit;
        pxBandwidthPackage[newPackageId].active = 1;

        // Add the new bandwidth package ID to the list of bandwidth package IDs
        bandwidthPackageIds.push(newPackageId);
    }

    // Function to get all storage packages
    function getAllPackages(uint256[] memory packageIds, mapping(uint256 => StoragePackage) storage pxStoragePackage) internal view returns (StoragePackage[] memory) {
        // Initialize an array to store the result
        StoragePackage[] memory result = new StoragePackage[](packageIds.length);

        // Populate the result array with storage packages
        for (uint256 i = 0; i < packageIds.length; i++) {
            result[i] = pxStoragePackage[packageIds[i]];
        }
        return result;
    }

    // Function to get all bandwidth packages
    function getAllBandwidthPackages(uint256[] memory packageIds, mapping(uint256 => BandwidthPackage) storage pxBandwidthPackage) internal view returns (BandwidthPackage[] memory) {
        // Initialize an array to store the result
        BandwidthPackage[] memory result = new BandwidthPackage[](packageIds.length);

        // Populate the result array with bandwidth packages
        for (uint256 i = 0; i < packageIds.length; i++) {
            result[i] = pxBandwidthPackage[packageIds[i]];
        }
        return result;
    }
    // Function to check if new data can be uploaded
    function canUpload(
        mapping(uint256 => Storage) storage pxStorage,
        uint256 tokenId,
        uint256 newUsage
    ) internal view returns (bool) {
        // Check if the last update was more than one day ago
        if (block.timestamp - pxStorage[tokenId].lastUpdateTimestamp > 1 days) {
            return false;
        }
        // Check if the new usage exceeds the allocated size or if there is no bandwidth left
        if (
            (pxStorage[tokenId].usage.add(newUsage)) >
            pxStorage[tokenId].sizeInBytes || pxStorage[tokenId].bandwidth == 0
        ) {
            return false;
        }
        return true;
    }

    // Function to get the token URI for a storage token
    function getTokenURI(
        mapping(uint256 => Storage) storage pxStorage,
        uint256 tokenId,
        uint256 currentUsage,
        uint256 storageSize,
        string memory storageUnit
    ) public view returns (string memory) {
        // Create the data URI for the token metadata
        bytes memory dataURI = abi.encodePacked(
            '{"name": "PollinationX #',
            tokenId.toString(),
            '","description": "Decentralized Storage Infra","image": "',
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
        // Encode the data URI to Base64 and return it
        return
            string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
}
