// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721MetadataStorage } from './metadata/ERC721MetadataInternal.sol';
import { IERC721Enumerable } from './enumerable/IERC721Enumerable.sol';
import { IERC721 } from './IERC721.sol';
import { ERC721 } from './ERC721.sol';
import { LibDiamond } from '../0_diamond/libraries/LibDiamond.sol';
import { DonationInternal } from '../2_donation/DonationInternal.sol';

contract ERC721SolidState is ERC721, DonationInternal {

    function init() external {
        _setName("Minter.Rocks DonationDAO");
        _setSymbol("DDAO");

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC721).interfaceId] = true;
        ds.supportedInterfaces[type(IERC721Enumerable).interfaceId] = true;
    }

    function pause() public {
        LibDiamond.enforceIsContractOwner();
        _pause();
    }

    function unpause() public {
        LibDiamond.enforceIsContractOwner();
        _unpause();
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        uint256 cardPower = _cardPower(tokenId);
        if(from != address(0)) {
            _decreaseUserPower(from, cardPower);
        }
        if(to != address(0)) {
            _increaseUserPower(to, cardPower);
        }
    }
    
}