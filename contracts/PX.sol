// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ISubscriptionOwner.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./libraries/PXStorage.sol";
import "./libraries/PXUtils.sol";

contract PX is ERC165, ISubscriptionOwner, ERC721URIStorage, Ownable {

    using Strings for uint256;
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    // Counters to keep track of token IDs, package IDs, and bandwidth package IDs
    Counters.Counter public _tokenIds;
    Counters.Counter public _packageIds;
    Counters.Counter public _bandwidthPackageIds;
    // Mappings to store package information, token storage data, and free package status
    mapping(address => PXStorage.FreePackage) public pxFreePackage;
    mapping(uint256 => PXStorage.Storage) public pxStorage;
    mapping(uint256 => PXStorage.StoragePackage) public pxStoragePackage;
    mapping(uint256 => PXStorage.BandwidthPackage) public pxBandwidthPackage;
    // Variables to manage contract state and configuration
    uint256 public paused = 0;
    uint256 public freePackageSize = 100; // 100MB
    uint256 private constant _maxPercentage = 100;
    uint256[] public packageIds;
    uint256[] public bandwidthPackageIds;

    // Constructor to initialize the contract with a default free package
    constructor() ERC721("PollinationX", "PXS") {
        pxStoragePackage[0].id = 0;
        pxStoragePackage[0].name = "100MB";
        pxStoragePackage[0].price = 0;
        pxStoragePackage[0].size = freePackageSize;
        pxStoragePackage[0].sizeInBytes = 104857600;
        pxStoragePackage[0].storageUnit = "MB";
        pxStoragePackage[0].active = 1;
        pxStoragePackage[0].bandwidthLimit = 25;
        packageIds.push(0);
    }

    // Function to mint a new token with a specified package
    function mint(uint256 packageId) public payable virtual {
        require(paused == 0);
        require(pxStoragePackage[packageId].active == 1);

        uint256 mintPrice = pxStoragePackage[packageId].price;

        if (msg.sender != owner()) {
            require(msg.value == mintPrice);
        }

        if (packageId == 0) {
            require(
                pxFreePackage[msg.sender].alreadyMinted != 1,
                "Already minted"
            );
            pxFreePackage[msg.sender].alreadyMinted = 1;
        }

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        // Initialize storage data for the new token
        pxStorage[newItemId].name = pxStoragePackage[packageId].name;
        pxStorage[newItemId].usage = 0;
        pxStorage[newItemId].usagePercentage = 0;
        pxStorage[newItemId].size = pxStoragePackage[packageId].size;
        pxStorage[newItemId].bandwidth = pxStoragePackage[packageId].bandwidthLimit;
        pxStorage[newItemId].storageUnit = pxStoragePackage[packageId]
            .storageUnit;
        pxStorage[newItemId].sizeInBytes = pxStoragePackage[packageId]
            .sizeInBytes;
        pxStorage[newItemId].buyTimestamp = block.timestamp;
        pxStorage[newItemId].lastUpdateTimestamp = block.timestamp;
        _setTokenURI(
            newItemId,
            PXStorage.getTokenURI(
                pxStorage,
                newItemId,
                0,
                pxStoragePackage[packageId].size,
                pxStorage[newItemId].storageUnit
            )
        );
    }

    // Function to pause or unpause the contract 1: paused, 0: active
    function pause(uint256 state) public onlyOwner {
        paused = state;
    }
    // Function to withdraw contract balance to the owner's address
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
                value: address(this).balance
            }("");
        require(success);
    }

    // Function to update storage usage for a token
    function updateStorageUsage(
        uint256 tokenId,
        uint256 usageInBytes,
        uint256 bandwidth
    ) public {
        require(_exists(tokenId));
        require(
            _isApprovedOrOwner(_msgSender(), tokenId) || owner() == _msgSender(),
            "!owner"
        );

        uint256 newUsage = (pxStorage[tokenId].usage).add(usageInBytes);

        require(newUsage <= pxStorage[tokenId].sizeInBytes, "Storage full");
        require(pxStorage[tokenId].bandwidth > 0, "No bandwidth");

        uint256 currentBandwidth = pxStorage[tokenId].bandwidth;
        uint256 newBandwidth = currentBandwidth > bandwidth ? pxStorage[tokenId].bandwidth.sub(bandwidth) : 0;

        // Update token storage data
        pxStorage[tokenId].usage = newUsage;
        pxStorage[tokenId].lastUpdateTimestamp = block.timestamp;
        pxStorage[tokenId].bandwidth = newBandwidth;
        pxStorage[tokenId].usagePercentage = PXUtils.calculatePercentageDifference(
            pxStorage[tokenId].sizeInBytes,
            newUsage
        );
        _setTokenURI(
            tokenId,
            PXStorage.getTokenURI(
                pxStorage,
                tokenId,
                pxStorage[tokenId].usagePercentage,
                pxStorage[tokenId].size,
                pxStorage[tokenId].storageUnit
            )
        );
    }

    // Function to unlock uploading for a token by updating the timestamp
    function unlockUploading(
        uint256 tokenId
    ) external onlyOwner {
        require(_exists(tokenId));
        pxStorage[tokenId].lastUpdateTimestamp = block.timestamp;
    }

    // Function to get storage usage in bytes for a token
    function getStorageUsageInBytes(
        uint256 tokenId
    ) external view returns (uint256) {
        return pxStorage[tokenId].usage;
    }

    // Function to check if a token owner can upload data
    function canUpload(
        uint256 tokenId,
        uint256 newUsage
    ) public view returns (bool canUploadStatus, bool sizeOrBandwidthExceeded, bool timestampLock) {
        return PXStorage.canUpload(pxStorage, tokenId, newUsage);
    }

    // Function to add a new storage package
    function addNewPackage(
        uint256 priceInWeiValue,
        uint256 sizeInGb,
        uint256 bandwidthLimit
    ) external onlyOwner {
        _packageIds.increment();
        uint256 newPackageId = _packageIds.current();
        PXStorage.addNewPackage(
            pxStoragePackage,
            packageIds,
            newPackageId,
            priceInWeiValue,
            sizeInGb,
            bandwidthLimit
        );
    }

    // Function to add a new bandwidth package
    function addNewBandwidthPackage(
        uint256 priceInWeiValue,
        uint256 bandwidthLimit
    ) external onlyOwner {
        uint256 newPackageId = _bandwidthPackageIds.current();
        PXStorage.addNewBandwidthPackage(
            pxBandwidthPackage,
            bandwidthPackageIds,
            newPackageId,
            priceInWeiValue,
            bandwidthLimit
        );
        _bandwidthPackageIds.increment();
    }

    // Function to upgrade the storage package of a token
    function upgradeTokenPackage(
        uint256 tokenId,
        uint256 packageId
    ) public payable virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId));
        require(
            pxStoragePackage[packageId].sizeInBytes >
            pxStorage[tokenId].sizeInBytes);

        uint256 mintPrice = pxStoragePackage[packageId].price;
        require(msg.value == mintPrice, "Storage price");

        // Update token storage data to reflect the upgraded package
        pxStorage[tokenId].usagePercentage = PXUtils.calculatePercentageDifference(
            pxStoragePackage[packageId].sizeInBytes,
            pxStorage[tokenId].usage
        );
        pxStorage[tokenId].size = pxStoragePackage[packageId].size;
        pxStorage[tokenId].bandwidth = pxStorage[tokenId].bandwidth.add(pxStoragePackage[packageId].bandwidthLimit);
        pxStorage[tokenId].storageUnit = pxStoragePackage[packageId]
            .storageUnit;
        pxStorage[tokenId].sizeInBytes = pxStoragePackage[packageId]
            .sizeInBytes;
        pxStorage[tokenId].lastUpdateTimestamp = block.timestamp;
        _setTokenURI(
            tokenId,
            PXStorage.getTokenURI(
                pxStorage,
                tokenId,
                pxStorage[tokenId].usagePercentage,
                pxStorage[tokenId].size,
                pxStorage[tokenId].storageUnit
            )
        );
    }

    // Function to purchase more bandwidth for a token
    function buyMoreBandwidth(
        uint256 tokenId,
        uint256 bandwidthPackageId
    ) public payable virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "!owner");

        uint256 mintPrice = pxBandwidthPackage[bandwidthPackageId].price;
        require(msg.value == mintPrice, "Bandwidth price");

        // Update token bandwidth data
        pxStorage[tokenId].bandwidth = pxStorage[tokenId].bandwidth.add(pxBandwidthPackage[bandwidthPackageId].bandwidth);

        _setTokenURI(
            tokenId,
            PXStorage.getTokenURI(
                pxStorage,
                tokenId,
                pxStorage[tokenId].usagePercentage,
                pxStorage[tokenId].size,
                pxStorage[tokenId].storageUnit
            )
        );
    }

    // Function to update the price of a storage package
    function updatePackagePrice(
        uint256 packageId,
        uint256 priceInWeiValue
    ) external onlyOwner {
        pxStoragePackage[packageId].price = priceInWeiValue;
    }

    // Function to activate or deactivate a storage package
    function activateDeactivatePackage(
        uint256 packageId,
        uint256 active
    ) external onlyOwner {
        // 1 active, 0 not active
        pxStoragePackage[packageId].active = active;
    }

    // Function to update the name of a token's package
    function updateTokenPackageName(
        uint256 tokenId,
        string memory name
    ) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "!owner");
        pxStorage[tokenId].name = name;
    }

    // Function to add extra content associated with a token
    function addExtraContent(
        uint256 tokenId,
        string memory hash,
        string memory content
    ) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "!owner");
        bytes32 contentHash = keccak256(abi.encodePacked(hash));
        pxStorage[tokenId].extraContent[contentHash].metadata = content;
        pxStorage[tokenId].extraContent[contentHash].active = 1;
    }

    // Function to retrieve extra content associated with a token
    function getExtraContent(
        uint256 tokenId,
        string memory hash
    ) public view returns (string memory) {
        bytes32 contentHash = keccak256(abi.encodePacked(hash));
        require(
            pxStorage[tokenId].extraContent[contentHash].active == 1,
            "Invalid Hash"
        );
        return pxStorage[tokenId].extraContent[contentHash].metadata;
    }

    // Function to retrieve all storage packages
    function getAllPackages() external view returns (PXStorage.StoragePackage[] memory) {
        return PXStorage.getAllPackages(packageIds, pxStoragePackage);
    }

    // Function to retrieve all bandwidth packages
    function getAllBandwidthPackages() external view returns (PXStorage.BandwidthPackage[] memory) {
        return PXStorage.getAllBandwidthPackages(bandwidthPackageIds, pxBandwidthPackage);
    }

    // Function to retrieve the owner of the subscription
    function getSubscriptionOwner() external view returns (address) {
        return owner();
    }

    // Function to check if the contract supports a given interface
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, ERC721URIStorage) returns (bool) {
        return
            interfaceId == type(ISubscriptionOwner).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
