// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";


abstract contract ERC1155Royalty is ERC2981, ERC1155Supply {

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(
        ERC1155, 
        ERC2981
    ) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual override {
        super._burn(from, id, amount);
        if(ERC1155Supply.totalSupply(id) == 0)
            _resetTokenRoyalty(id);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual override {
        super._burnBatch(from, ids, amounts);
        for (uint256 i = 0; i < ids.length; i++) 
            if(ERC1155Supply.totalSupply(ids[i]) == 0)
                _resetTokenRoyalty(ids[i]);
    }
}
