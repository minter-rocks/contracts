// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721BaseInternal } from '../base/ERC721BaseInternal.sol';
import { ERC721MetadataStorage } from './ERC721MetadataStorage.sol';

/**
 * @title ERC721Metadata internal functions
 */
abstract contract ERC721MetadataInternal is ERC721BaseInternal {

    function _setName(string memory _name) internal virtual {
        ERC721MetadataStorage.layout().name = _name;
    }

    function _setSymbol(string memory _symbol) internal virtual {
        ERC721MetadataStorage.layout().symbol = _symbol;
    }

    function _setBaseURI(string memory _baseURI) internal virtual {
        ERC721MetadataStorage.layout().baseURI = _baseURI;
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) internal virtual {
        ERC721MetadataStorage.layout().tokenURIs[_tokenId] = _tokenURI;
    }

    /**
     * @notice ERC721 hook: clear per-token URI data on burn
     * @inheritdoc ERC721BaseInternal
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (to == address(0)) {
            delete ERC721MetadataStorage.layout().tokenURIs[tokenId];
        }
    }
}
