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

    string public collectionInfo;
    string public name;
    string public symbol;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _collectionInfo,
        string memory _name,
        string memory _symbol,
        address _owner
    ) initializer public {
        collectionInfo = _collectionInfo;
        name = _name;
        symbol = _symbol;
        __Ownable_init(_owner);
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
    }

    function setURI(uint256 tokenId, string memory newuri) public onlyOwner {
        _setURI(tokenId, newuri);
    }

    function newId(
        uint256 id_, 
        uint256 cap_,
        string memory uri_
    ) public onlyOwner {
        require(!exists(id_), "id already exists");
        _setCap(id_, cap_);
        _setURI(id_, uri_);
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
        for (uint256 i = 0; i < ids.length; i++) {
            require(exists(ids[i]), "non-existant id");
        }
        _mintBatch(to, ids, amounts, "");
    }

    function exists(uint256 id) public view override returns (bool) {
        return ERC1155CappedUpgradeable.cap(id) > 0;
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