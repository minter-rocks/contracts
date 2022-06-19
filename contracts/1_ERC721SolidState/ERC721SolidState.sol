// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721MetadataStorage } from './metadata/ERC721MetadataInternal.sol';
import { IERC721Enumerable } from './enumerable/IERC721Enumerable.sol';
import { IERC721 } from './IERC721.sol';
import { ERC721 } from './ERC721.sol';
import { LibDiamond } from '../0_diamond/libraries/LibDiamond.sol';

contract ERC721SolidState is ERC721 {

    function init() external {
        _setName("Minter.Rocks Donation");
        _setSymbol("Donate");

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC721).interfaceId] = true;
        ds.supportedInterfaces[type(IERC721Enumerable).interfaceId] = true;
    }
}