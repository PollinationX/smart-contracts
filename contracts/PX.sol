// SPDX-License-Identifier: Open Source With Commercial Restrictions
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PX is ERC721URIStorage, Ownable {

    struct StoragePackage {
        string name;
        uint256 price;
        uint256 size;
        uint256 sizeInBytes;
        string storageUnit;
        uint256 active;
    }
    struct Storage {
        string  name;
        uint256 usage;
        uint256 usagePercentage;
        uint256 size;
        uint256 sizeInBytes;
        string storageUnit;
        uint256 buyTimestamp;
        uint256 lastUpdateTimestamp;
    }
    struct FreePackage {
        uint256 alreadyMinted;
    }

    using Strings for uint256;
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _packageIds;
    mapping(address => FreePackage) public pxFreePackage;
    mapping(uint256 => Storage) public pxStorage;
    mapping(uint256 => StoragePackage) public pxStoragePackage;
    uint256 public paused = 1;
    uint256 public freePackageSize = 100; // 100MB
    uint256 private constant _maxPercentage = 100;
    uint256 private constant _gbToBytes = 1073741824;

    constructor() ERC721 ("PollinationX", "PXS"){
        pxStoragePackage[0].name = "100MB";
        pxStoragePackage[0].price = 0;
        pxStoragePackage[0].size = freePackageSize;
        pxStoragePackage[0].sizeInBytes = 104857600;
        pxStoragePackage[0].storageUnit = "MB";
        pxStoragePackage[0].active = 1;
    }

    function getProgressImage(uint256 tokenId, string memory storageUnit) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 250 350"><defs><style>.cls-1, .cls-3, .cls-4 {fill: #fff;font-size: 21px;}.cls-5 {fill: #fab432;}.cls-6 {fill: #222;}.cls-7 {letter-spacing: -.01em;}.cls-8 {letter-spacing: -.01em;}.cls-9, .cls-10 {letter-spacing: -.03em;}.cls-11 {letter-spacing: 0em;}.cls-12 {letter-spacing: 0em;}.cls-13 {fill: #878989;font-size: 18px;}</style></defs>',
            '<rect class="cls-6" width="250" height="350"/><path class="cls-5" d="m125.88,125.5l-37.48,21.66v43.52l34.37,19.83,2.74,8.16h.8l2.69-8.17,34.32-19.83v-43.52l-37.44-21.66Zm15.42,72.71l-15.42,8.9-15.45-8.92v-8.59s15.45,8.92,15.45,8.92l15.45-8.92-.03,8.6Zm-15.42-4.89l-15.45-8.92v-8.59s15.45,8.92,15.45,8.92l15.42-8.9.03,8.57-15.45,8.92Zm15.42-22.69l-15.42,8.9-15.45-8.92v-8.59l15.45,8.92,15.42-8.9v8.59Zm-15.42-4.89l-12.99-7.5,12.99-7.5,12.99,7.5-12.99,7.5Zm-4.82-17.41l-12.87,7.43-12.87-7.43,12.87-7.43,12.87,7.43Zm22.5,7.42l-12.85-7.42,12.86-7.42,12.85,7.42-12.86,7.42Zm-4.57-17.45l-13.1,7.57-13.1-7.57,13.1-7.57,13.1,7.57Zm-46.11,13.77l13.06,7.54v8.46l-13.06-7.54v-8.46Zm0,13.62l13.06,7.54v8.61l-13.06-7.54v-8.61Zm0,13.77l13.06,7.54v8.63l-13.06-7.54v-8.63Zm65.98,8.63l-13.03,7.52v-8.62h0s13.03-7.53,13.03-7.53v8.63Zm0-13.79l-13.03,7.52v-8.61l13.03-7.52v8.61Zm-13.03-6.25v-8.46l13.03-7.52v8.46l-13.03,7.52Z"/>',
            '<text class="cls-3" transform="translate(88.79 247.36)"><tspan class="cls-11" x="0" y="0">US</tspan><tspan class="cls-8" x="29.36" y="0">A</tspan><tspan class="cls-11" x="44.88" y="0">GE</tspan></text>',
            '<text class="cls-3" transform="translate(45.16 109.16)"><tspan class="cls-12" x="0" y="0">S</tspan><tspan class="cls-10" x="13.4" y="0">T</tspan><tspan class="cls-12" x="26.21" y="0">OR</tspan><tspan class="cls-7" x="57.71" y="0">A</tspan><tspan class="cls-11" x="73.23" y="0">GE SIZE</tspan><tspan class="cls-2" x="155.54" y="0"> </tspan></text>',
            '<text class="cls-9" transform="translate(104.4 85.2)"><tspan class="cls-13" x="0" y="0">',pxStorage[tokenId].size.toString(),storageUnit,'</tspan><tspan class="cls-4" x="37.08" y="0"> </tspan></text>',
            '<text class="cls-9" transform="translate(106.11 271.46)"><tspan class="cls-13" x="0" y="0">',pxStorage[tokenId].usagePercentage.toString(),'%</tspan><tspan class="cls-1" x="33.66" y="0"> </tspan></text></svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }
    function getTokenURI(uint256 tokenId, uint256 currentUsage, uint256 storageSize, string memory storageUnit) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
            '"name": "PollinationX #', tokenId.toString(), '",',
            '"description": "Decentralized Storage On Demand",',
            '"image": "', getProgressImage(tokenId, storageUnit), '",',
            '"attributes": [{"display_type": "boost_percentage","trait_type": "Usage","value": ',currentUsage.toString(), '},{"trait_type": "Capacity","value": "',storageSize.toString(),storageUnit,'"}]',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
    function mint(uint256 packageId) public virtual payable {
        require(paused == 1, "Minting paused");
        require(pxStoragePackage[packageId].active == 1, "Package is not active");

        uint256 mintPrice = pxStoragePackage[packageId].price;
        require(msg.value == mintPrice, "Not enough tokens sent. Check storage fee");

        if(packageId == 0){
            require(pxFreePackage[msg.sender].alreadyMinted != 1, "Free package already minted");
            pxFreePackage[msg.sender].alreadyMinted = 1;
        }

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        pxStorage[newItemId].name = pxStoragePackage[packageId].name;
        pxStorage[newItemId].usage = 0;
        pxStorage[newItemId].usagePercentage = 0;
        pxStorage[newItemId].size = pxStoragePackage[packageId].size;
        pxStorage[newItemId].storageUnit = pxStoragePackage[packageId].storageUnit;
        pxStorage[newItemId].sizeInBytes = pxStoragePackage[packageId].sizeInBytes;
        pxStorage[newItemId].buyTimestamp = block.timestamp;
        pxStorage[newItemId].lastUpdateTimestamp = block.timestamp;
        _setTokenURI(newItemId, getTokenURI(newItemId,0,pxStoragePackage[packageId].size, pxStorage[newItemId].storageUnit));
    }
    function pause(uint256 state) public onlyOwner {
        paused = state;
    }
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
    function updateStorageUsage(uint256 tokenId, uint256 usageInBytes) external onlyOwner() {
        require(_exists(tokenId), "Incorrect tokenId");
        uint256 newUsage = (pxStorage[tokenId].usage).add(usageInBytes);
        require(newUsage <= pxStorage[tokenId].sizeInBytes, "Your storage is full");
        pxStorage[tokenId].usage = newUsage;
        pxStorage[tokenId].lastUpdateTimestamp = block.timestamp;
        pxStorage[tokenId].usagePercentage = calculatePercentageDifference(pxStorage[tokenId].sizeInBytes, newUsage);
        _setTokenURI(tokenId, getTokenURI(tokenId,pxStorage[tokenId].usagePercentage,pxStorage[tokenId].size, pxStorage[tokenId].storageUnit));
    }
    function getStorageUsageInBytes(uint256 tokenId) external view returns (uint256) {
        return pxStorage[tokenId].usage;
    }
    function calculatePercentageDifference(uint256 oldValue, uint256 newValue) public pure returns (uint256) {
        uint256 difference = oldValue.sub(newValue);
        uint256 percentageDifference = (difference.mul(100)).div(oldValue);
        return _maxPercentage.sub(percentageDifference);
    }
    function canUpload(uint256 tokenId, uint256 newUsage) public view returns (bool) {
        if((pxStorage[tokenId].usage.add(newUsage)) > pxStorage[tokenId].sizeInBytes){
            return false;
        }
        return true;
    }
    function addNewPackage(uint256 priceInWeiValue, uint256 sizeInGb) external onlyOwner() {
        _packageIds.increment();
        uint256 newPackageId = _packageIds.current();
        pxStoragePackage[newPackageId].name = newPackageId.toString();
        pxStoragePackage[newPackageId].price = priceInWeiValue;
        pxStoragePackage[newPackageId].size = sizeInGb;
        pxStoragePackage[newPackageId].sizeInBytes = sizeInGb.mul(_gbToBytes);
        pxStoragePackage[newPackageId].storageUnit = "GB";
        pxStoragePackage[newPackageId].active = 1;
    }
    function upgradeTokenPackage(uint256 tokenId, uint256 packageId) public virtual payable {
        require(_exists(tokenId), "Incorrect tokenId");
        require(_isApprovedOrOwner(_msgSender(), tokenId),"Not NFT owner");
        require(pxStoragePackage[packageId].sizeInBytes > pxStorage[tokenId].sizeInBytes, "Choose bigger package");

        uint256 mintPrice = pxStoragePackage[packageId].price;
        require(msg.value == mintPrice, "Not enough tokens sent. Check storage fee");

        pxStorage[tokenId].usagePercentage = calculatePercentageDifference(pxStoragePackage[packageId].sizeInBytes, pxStorage[tokenId].usage);
        pxStorage[tokenId].size = pxStoragePackage[packageId].size;
        pxStorage[tokenId].storageUnit = pxStoragePackage[packageId].storageUnit;
        pxStorage[tokenId].sizeInBytes = pxStoragePackage[packageId].sizeInBytes;
        pxStorage[tokenId].lastUpdateTimestamp = block.timestamp;
        _setTokenURI(tokenId, getTokenURI(tokenId,pxStorage[tokenId].usagePercentage,pxStorage[tokenId].size, pxStorage[tokenId].storageUnit));
    }
    function updatePackagePrice(uint256 packageId, uint256 priceInWeiValue) external onlyOwner() {
        pxStoragePackage[packageId].price = priceInWeiValue;
    }
    function activateDeactivatePackage(uint256 packageId, uint256 active) external onlyOwner() { // 1 active, 0 not active
        pxStoragePackage[packageId].active = active;
    }
    function updateTokenPackageName(uint256 tokenId, string memory name) public {
        require(_exists(tokenId), "Incorrect tokenId");
        require(_isApprovedOrOwner(_msgSender(), tokenId),"Not NFT owner");
        pxStorage[tokenId].name = name;
    }
}
