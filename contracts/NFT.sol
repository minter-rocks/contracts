// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IDCardOwnable.sol";

contract IDCardSubNFT is ERC721, IDCardOwnable {

    function version() public pure returns(string memory V_) {
        V_ = "0.0.0";
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor(uint256 ownerID_) 
        ERC721("ID-Card-subNFT", "subIDC")
        IDCardOwnable(ownerID_)
    {}

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}