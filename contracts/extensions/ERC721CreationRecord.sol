// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721CreationRecord is ERC721 {
    struct CreatedToken{
        address creatorAddr;
        uint256 creationTime;
    }

    mapping(uint256 => CreatedToken) createdTokens;

    modifier onlyCreator(uint256 tokenId) {
        require(msg.sender == creatorOf(tokenId), "BanTheBanNFT: only creator of the token can set Royalty");
        _;
    }

    function creationTime(uint256 tokenId) public view returns(uint256) {
        return createdTokens[tokenId].creationTime;
    }

    function creatorOf(uint256 tokenId) public view returns(address) {
        return createdTokens[tokenId].creatorAddr;
    }


    function _burn(uint256 tokenId) internal override {
        super._burn(tokenId);
        delete createdTokens[tokenId];
    }

    function _mint(address to, uint256 tokenId) internal override {
        super._mint(to, tokenId);
        createdTokens[tokenId] = CreatedToken(_msgSender(), block.timestamp);
    }
}