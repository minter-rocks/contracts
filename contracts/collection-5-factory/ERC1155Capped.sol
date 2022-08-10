// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

abstract contract ERC1155Capped is ERC1155Supply {
    mapping (uint256 => uint256) private _cap;

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap(uint256 tokenId) public view virtual returns (uint256) {
        return _cap[tokenId];
    }

    function _setCap(uint256 tokenId, uint256 supplyCap) internal {
        _cap[tokenId] = supplyCap;
    }

    function _mint(
        address account, 
        uint256 id, 
        uint256 amount, 
        bytes memory data
    ) internal virtual override {
        require(ERC1155Supply.totalSupply(id) + amount <= cap(id), "ERC1155Capped: cap exceeded");
        super._mint(account, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        for (uint256 i = 0; i < ids.length; i++) {
            require(ERC1155Supply.totalSupply(ids[i]) + amounts[i] <= cap(ids[i]), "ERC1155Capped: cap exceeded");
        }
        super._mintBatch(to, ids, amounts, data);
    }
}
