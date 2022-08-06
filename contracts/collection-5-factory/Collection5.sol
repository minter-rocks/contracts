// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./ERC1155Capped.sol";

contract Collection5 is 
    Initializable, 
    ERC1155Upgradeable, 
    OwnableUpgradeable, 
    ERC1155BurnableUpgradeable, 
    ERC1155SupplyUpgradeable, 
    ERC1155URIStorageUpgradeable, 
    ERC1155CappedUpgradeable 
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address owner) initializer public {
        __ERC1155_init("https://someURI/");
        __Ownable_init(owner);
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
    }

    function setURI(uint256 tokenId, string memory newuri) public onlyOwner {
        _setURI(tokenId, newuri);
    }

    function newId(
        address account, 
        uint256 id, 
        uint256 supplyCap,
        uint256 initialAmount
    ) public onlyOwner {
        require(!exists(id), "id already exists");
        _setCap(id, supplyCap);
        _mint(account, id, initialAmount, "");
    }

    function mint(address account, uint256 id, uint256 amount)
        public
        onlyOwner
    {
        require(exists(id), "non-existant id");
        _mint(account, id, amount, "");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, "");
    }

    // The following functions are overrides required by Solidity.

    function uri(uint256 tokenId) public view virtual 
        override(ERC1155Upgradeable, ERC1155URIStorageUpgradeable)
        returns (string memory) 
    {
        return super.uri(tokenId);
    }

    function _mint(
        address account, 
        uint256 id, 
        uint256 amount, 
        bytes memory data
    ) internal virtual override(ERC1155Upgradeable, ERC1155CappedUpgradeable) {
        super._mint(account, id, amount, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}