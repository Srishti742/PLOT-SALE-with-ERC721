// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract PlotToken is ERC721, ERC721Enumerable, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
 
    struct Plot {
        uint priceInWei;
        uint paidWei;
    }

    mapping (uint => Plot) public mapingPrice;
    mapping (uint => uint) public tokenPrice;

    constructor() ERC721("PlotToken", "PLO") 
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://Plots.sellbuy/metadata/";
    }

    
    function _beforeTokenTransfer(address from, address to, uint _tokenId) internal override(ERC721, ERC721Enumerable) {
        require(! _exists(_tokenId) || mapingPrice[_tokenId].paidWei == mapingPrice[_tokenId].priceInWei ,"Token not bought");
        super._beforeTokenTransfer(from, to, _tokenId);
    }

    function buyPlotToken(address fromBuyer, address toSeller, uint _tokenId) public payable {
        
        require(msg.value == mapingPrice[_tokenId].priceInWei, "We don't support partial payments");
        require(mapingPrice[_tokenId].paidWei == 0, "Item is already paid!");
        mapingPrice[_tokenId].paidWei += msg.value;

    }

    function mintPlotToken(address to, uint _priceInWei) public {
        uint _tokenId = _tokenIdCounter.current();
        mapingPrice[_tokenId].priceInWei = _priceInWei;
        tokenPrice[_tokenIdCounter.current()] = _priceInWei;
        _tokenIdCounter.increment();
        super._safeMint(to, _tokenId);
    }

    

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}