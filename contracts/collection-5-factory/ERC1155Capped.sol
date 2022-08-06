// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";

abstract contract ERC1155CappedUpgradeable is ERC1155SupplyUpgradeable {
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

    /**
     * @dev See {ERC1155-_mint}.
     */
    function _mint(
        address account, 
        uint256 id, 
        uint256 amount, 
        bytes memory data
    ) internal virtual override {
        require(ERC1155SupplyUpgradeable.totalSupply(id) + amount <= cap(id), "ERC1155Capped: cap exceeded");
        super._mint(account, id, amount, data);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
