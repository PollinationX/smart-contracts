// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PX is ERC721URIStorage, Ownable  {

    struct Storage {
        uint256 usage;
        uint256 usagePercentage;
        uint256 sizeInGb;
        uint256 sizeInBytes;
        uint256 buyTimestamp;
        uint256 expirationTimestamp;
        uint256 lastUpdateTimestamp;
    }
    struct StoragePackage {
        string name;
        uint256 price;
        uint256 sizeInGb;
        uint256 sizeInBytes;
        uint256 active;
        uint256 creationTimestamp;
        uint256 lastUpdateTimestamp;
    }

    using Strings for uint256;
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(uint256 => Storage) public pxStorage;
    mapping(uint256 => StoragePackage) public pxStoragePackage;
    bool public paused = false;
    uint256 public minimumStorageSize = 1; // minimum is 1GB
    uint256 public freePackageSize = (1 ether/10); // 100MB
    uint256 public packageOneSize = 5; // 5GB
    uint256 public packageTwoSize = 10; // 10GB
    uint256 public packageThreeSize = 20; // 20GB
    uint256 public packageFourSize = 100; // 100GB
    string public storageUnit = "GB";
    uint public constant baseMintPrice = (1 ether/100);
    uint256 private constant _gbToBytes = 1073741824;
    uint private constant _maxPercentage = 100;

    constructor() ERC721 ("PollinationX", "PXS"){
        pxStoragePackage[0].name = "Free package";
        pxStoragePackage[0].price = 0;
        pxStoragePackage[0].sizeInGb = freePackageSize;
        pxStoragePackage[0].sizeInBytes = freePackageSize.mul(_gbToBytes);
        pxStoragePackage[0].active = 1;
        pxStoragePackage[0].creationTimestamp = block.timestamp;
        pxStoragePackage[0].lastUpdateTimestamp = block.timestamp;

        pxStoragePackage[1].name = "5GB";
        pxStoragePackage[1].price = (5 ether);
        pxStoragePackage[1].sizeInGb = packageOneSize;
        pxStoragePackage[1].sizeInBytes = packageOneSize.mul(_gbToBytes);
        pxStoragePackage[1].active = 1;
        pxStoragePackage[1].creationTimestamp = block.timestamp;
        pxStoragePackage[1].lastUpdateTimestamp = block.timestamp;

        pxStoragePackage[2].name = "10GB";
        pxStoragePackage[2].price = (10 ether);
        pxStoragePackage[2].sizeInGb = packageTwoSize;
        pxStoragePackage[2].sizeInBytes = packageTwoSize.mul(_gbToBytes);
        pxStoragePackage[2].active = 1;
        pxStoragePackage[2].creationTimestamp = block.timestamp;
        pxStoragePackage[2].lastUpdateTimestamp = block.timestamp;

        pxStoragePackage[3].name = "20GB";
        pxStoragePackage[3].price = (20 ether);
        pxStoragePackage[3].sizeInGb = packageThreeSize;
        pxStoragePackage[3].sizeInBytes = packageThreeSize.mul(_gbToBytes);
        pxStoragePackage[3].active = 1;
        pxStoragePackage[3].creationTimestamp = block.timestamp;
        pxStoragePackage[3].lastUpdateTimestamp = block.timestamp;

        pxStoragePackage[4].name = "100GB";
        pxStoragePackage[4].price = (90 ether);
        pxStoragePackage[4].sizeInGb = packageFourSize;
        pxStoragePackage[4].sizeInBytes = packageFourSize.mul(_gbToBytes);
        pxStoragePackage[4].active = 1;
        pxStoragePackage[4].creationTimestamp = block.timestamp;
        pxStoragePackage[4].lastUpdateTimestamp = block.timestamp;
    }

    function getProgressImage(uint256 tokenId) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 250 350">',
            '<defs>',
            '<style>.cls-1, .cls-2 {letter-spacing: 0em;}.cls-1, .cls-3, .cls-4 {fill: #fff;font-size: 21px;}',
            '.cls-5 {fill: #fab432;}.cls-6 {fill: #222;}.cls-7 {letter-spacing: -.01em;}.cls-8 {letter-spacing: -.01em;}',
            '.cls-9, .cls-3 {font-family: Metropolis-Bold, Metropolis;font-weight: 700;}.cls-10 {letter-spacing: -.03em;}',
            '.cls-11 {letter-spacing: 0em;}.cls-12 {letter-spacing: 0em;}.cls-13 {fill: #878989;font-size: 18px;}</style>',
            '</defs>',
            '<rect class="cls-6" width="250" height="350"/>',
            '<path class="cls-5" d="m125.88,125.5l-37.48,21.66v43.52l34.37,19.83,2.74,8.16h.8l2.69-8.17,34.32-19.83v-43.52l-37.44-21.66Zm15.42,72.71l-15.42,8.9-15.45-8.92v-8.59s15.45,8.92,15.45,8.92l15.45-8.92-.03,8.6Zm-15.42-4.89l-15.45-8.92v-8.59s15.45,8.92,15.45,8.92l15.42-8.9.03,8.57-15.45,8.92Zm15.42-22.69l-15.42,8.9-15.45-8.92v-8.59l15.45,8.92,15.42-8.9v8.59Zm-15.42-4.89l-12.99-7.5,12.99-7.5,12.99,7.5-12.99,7.5Zm-4.82-17.41l-12.87,7.43-12.87-7.43,12.87-7.43,12.87,7.43Zm22.5,7.42l-12.85-7.42,12.86-7.42,12.85,7.42-12.86,7.42Zm-4.57-17.45l-13.1,7.57-13.1-7.57,13.1-7.57,13.1,7.57Zm-46.11,13.77l13.06,7.54v8.46l-13.06-7.54v-8.46Zm0,13.62l13.06,7.54v8.61l-13.06-7.54v-8.61Zm0,13.77l13.06,7.54v8.63l-13.06-7.54v-8.63Zm65.98,8.63l-13.03,7.52v-8.62h0s13.03-7.53,13.03-7.53v8.63Zm0-13.79l-13.03,7.52v-8.61l13.03-7.52v8.61Zm-13.03-6.25v-8.46l13.03-7.52v8.46l-13.03,7.52Z"/>',
            '<text class="cls-3" transform="translate(88.79 247.36)"><tspan class="cls-11" x="0" y="0">US</tspan><tspan class="cls-8" x="29.36" y="0">A</tspan><tspan class="cls-11" x="44.88" y="0">GE</tspan></text>',
            '<text class="cls-3" transform="translate(45.16 109.16)"><tspan class="cls-12" x="0" y="0">S</tspan><tspan class="cls-10" x="13.4" y="0">T</tspan><tspan class="cls-12" x="26.21" y="0">OR</tspan><tspan class="cls-7" x="57.71" y="0">A</tspan><tspan class="cls-11" x="73.23" y="0">GE SIZE</tspan><tspan class="cls-2" x="155.54" y="0"> </tspan></text>',
            '<text class="cls-9" transform="translate(104.4 85.2)"><tspan class="cls-13" x="0" y="0">',pxStorage[tokenId].sizeInGb.toString(),storageUnit,'</tspan><tspan class="cls-4" x="37.08" y="0"> </tspan></text>',
            '<text class="cls-9" transform="translate(106.11 271.46)"><tspan class="cls-13" x="0" y="0">',pxStorage[tokenId].usagePercentage.toString(),'%</tspan><tspan class="cls-1" x="33.66" y="0"> </tspan></text>',
            '</svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }
    function getTokenURI(uint256 tokenId, uint256 currentUsage, uint256 storageSize) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
            '"name": "PollinationX #', tokenId.toString(), '",',
            '"description": "Decentralized Storage On Demand",',
            '"image": "', getProgressImage(tokenId), '",',
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
    function mint(uint256 storageSize) public virtual payable {
        require(!paused, "Minting is disabled");
        require(storageSize >= minimumStorageSize, "You can't buy less than minimum storage offer");
        uint256 mintPrice = baseMintPrice.mul(storageSize);
        require(msg.value == mintPrice, "Not enough tokens sent; Price must be equal to storage fee");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        pxStorage[newItemId].usage = 0;
        pxStorage[newItemId].usagePercentage = 0;
        pxStorage[newItemId].sizeInGb = storageSize;
        pxStorage[newItemId].sizeInBytes = storageSize.mul(_gbToBytes);
        pxStorage[newItemId].buyTimestamp = block.timestamp;
        pxStorage[newItemId].lastUpdateTimestamp = block.timestamp;
        pxStorage[newItemId].expirationTimestamp = 0;
        _setTokenURI(newItemId, getTokenURI(newItemId,0,storageSize));
    }
    function setMinimumStorageSize(uint256 amount) external onlyOwner() {
        minimumStorageSize = amount;
    }
    function getMinimumStorageSize() external view returns (uint256) {
        return minimumStorageSize;
    }
    function getBaseMintPrice() external pure returns (uint256) {
        return baseMintPrice;
    }
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    function updateStorageUsage(uint256 tokenId, uint256 usageInBytes) external onlyOwner() {
        require(_exists(tokenId), "Please use an existing token");

        uint256 currentUsage = pxStorage[tokenId].usage;
        uint256 newUsage = currentUsage.add(usageInBytes);

        require(newUsage <= pxStorage[tokenId].sizeInBytes, "Your storage is full. Please mint the new PollinationX NFT");
        pxStorage[tokenId].usage = newUsage;
        pxStorage[tokenId].lastUpdateTimestamp = block.timestamp;
        pxStorage[tokenId].usagePercentage = calculatePercentageDifference(pxStorage[tokenId].sizeInBytes, newUsage);
        _setTokenURI(tokenId, getTokenURI(tokenId,pxStorage[tokenId].usagePercentage,pxStorage[tokenId].sizeInGb));
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
        uint tmpUsage = pxStorage[tokenId].usage.add(newUsage);
        if(tmpUsage > pxStorage[tokenId].sizeInBytes){
            return false;
        }
        return true;
    }
}
