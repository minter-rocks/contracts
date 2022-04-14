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

    function creationTime(uint256 tokenId) public view returns(uint256) {
        return createdTokens[tokenId].creationTime;
    }

    function creatorAddr(uint256 tokenId) public view returns(address) {
        return createdTokens[tokenId].creatorAddr;
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            createdTokens[tokenId] = CreatedToken(_msgSender(), block.timestamp);
        } else if(to == address(0)) {
            delete createdTokens[tokenId];
        }
    }
}