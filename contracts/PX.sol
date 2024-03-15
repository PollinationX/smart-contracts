// SPDX-License-Identifier: Open Source With Commercial Restrictions
pragma solidity ^0.8.10;

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

    event MintNewNftPackage(
        address msgSender,
        uint256 packageId,
        uint256 tokenId,
        uint256 mintPrice,
        uint256 msgValue
    );

    using Strings for uint256;
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _packageIds;
    Counters.Counter private _bandwidthPackageIds;
    mapping(address => PXStorage.FreePackage) public pxFreePackage;
    mapping(uint256 => PXStorage.Storage) public pxStorage;
    mapping(uint256 => PXStorage.StoragePackage) public pxStoragePackage;
    mapping(uint256 => PXStorage.BandwidthPackage) public pxBandwidthPackage;
    uint256 public paused = 0;
    uint256 public freePackageSize = 100; // 100MB
    uint256 private constant _maxPercentage = 100;
    uint256 private constant _gbToBytes = 1073741824;
    uint256[] public packageIds;
    uint256[] public bandwidthPackageIds;

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

    function mint(uint256 packageId) public payable virtual {
        require(paused == 0, "Paused");
        require(pxStoragePackage[packageId].active == 1, "Not active");

        uint256 mintPrice = pxStoragePackage[packageId].price;
        require(msg.value == mintPrice, "Check storage fee");

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

        emit MintNewNftPackage(
            msg.sender,
            packageId,
            newItemId,
            mintPrice,
            msg.value
        );
    }

    // 1: paused, 0: active
    function pause(uint256 state) public onlyOwner {
        paused = state;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
                value: address(this).balance
            }("");
        require(success);
    }

    function updateStorageUsage(
        uint256 tokenId,
        uint256 usageInBytes
    ) external onlyOwner {
        require(_exists(tokenId), "Incorrect tokenId");
        uint256 newUsage = (pxStorage[tokenId].usage).add(usageInBytes);
        require(newUsage <= pxStorage[tokenId].sizeInBytes, "Storage is full");
        require(pxStorage[tokenId].bandwidth < 1, "No bandwidth available");

        uint256 newBandwidth = pxStorage[tokenId].bandwidth.sub(1);

        if(newBandwidth < 0){
            newBandwidth = 0;
        }

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

    function getStorageUsageInBytes(
        uint256 tokenId
    ) external view returns (uint256) {
        return pxStorage[tokenId].usage;
    }

    function canUpload(
        uint256 tokenId,
        uint256 newUsage
    ) public view returns (bool) {
        return PXStorage.canUpload(pxStorage, tokenId, newUsage);
    }

    function addNewPackage(
        uint256 priceInWeiValue,
        uint256 sizeInGb,
        uint256 bandwidthLimit
    ) external onlyOwner {
        _packageIds.increment();
        uint256 newPackageId = _packageIds.current();
        pxStoragePackage[newPackageId].id = newPackageId;
        pxStoragePackage[newPackageId].name = newPackageId.toString();
        pxStoragePackage[newPackageId].price = priceInWeiValue;
        pxStoragePackage[newPackageId].size = sizeInGb;
        pxStoragePackage[newPackageId].sizeInBytes = sizeInGb.mul(_gbToBytes);
        pxStoragePackage[newPackageId].storageUnit = "GB";
        pxStoragePackage[newPackageId].active = 1;
        pxStoragePackage[newPackageId].bandwidthLimit = bandwidthLimit;
        packageIds.push(newPackageId);
    }
    function addNewBandwidthPackage(
        uint256 priceInWeiValue,
        uint256 bandwidthLimit
    ) external onlyOwner {
        uint256 newPackageId = _bandwidthPackageIds.current();
        pxBandwidthPackage[newPackageId].id = newPackageId;
        pxBandwidthPackage[newPackageId].name = bandwidthLimit.toString();
        pxBandwidthPackage[newPackageId].price = priceInWeiValue;
        pxBandwidthPackage[newPackageId].bandwidth = bandwidthLimit;
        pxBandwidthPackage[newPackageId].active = 1;
        bandwidthPackageIds.push(newPackageId);

        _bandwidthPackageIds.increment();
        bandwidthPackageIds.push(newPackageId);
    }

    function upgradeTokenPackage(
        uint256 tokenId,
        uint256 packageId
    ) public payable virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "!NFT owner");
        require(
            pxStoragePackage[packageId].sizeInBytes >
            pxStorage[tokenId].sizeInBytes,
            "Choose bigger package"
        );

        uint256 mintPrice = pxStoragePackage[packageId].price;
        require(msg.value == mintPrice, "Storage fee");

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

    function buyMoreBandwidth(
        uint256 tokenId,
        uint256 bandwidthPackageId
    ) public payable virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "!NFT owner");

        uint256 mintPrice = pxBandwidthPackage[bandwidthPackageId].price;
        require(msg.value == mintPrice, "Bandwidth fee");

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

    function updatePackagePrice(
        uint256 packageId,
        uint256 priceInWeiValue
    ) external onlyOwner {
        pxStoragePackage[packageId].price = priceInWeiValue;
    }

    function activateDeactivatePackage(
        uint256 packageId,
        uint256 active
    ) external onlyOwner {
        // 1 active, 0 not active
        pxStoragePackage[packageId].active = active;
    }

    function updateTokenPackageName(
        uint256 tokenId,
        string memory name
    ) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "!NFT owner");
        pxStorage[tokenId].name = name;
    }

    function addExtraContent(
        uint256 tokenId,
        string memory hash,
        string memory content
    ) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "!NFT owner");
        bytes32 contentHash = keccak256(abi.encodePacked(hash));
        pxStorage[tokenId].extraContent[contentHash].metadata = content;
        pxStorage[tokenId].extraContent[contentHash].active = 1;
    }

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

    function getAllPackages() external view returns (PXStorage.StoragePackage[] memory) {
        return PXStorage.getAllPackages(packageIds, pxStoragePackage);
    }

    function getSubscriptionOwner() external view returns (address) {
        return owner();
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, ERC721URIStorage) returns (bool) {
        return
            interfaceId == type(ISubscriptionOwner).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
