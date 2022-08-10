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
        address _owner,
        uint96 _royaltyNumerator,
        address _royaltyReciever
    ) initializer public {
        collectionInfo = _collectionInfo;
        name = _name;
        symbol = _symbol;
        __Ownable_init(_owner);
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        if (_royaltyNumerator > 0) {
            require(_royaltyReciever != address(0), "Collection: Invalid Royalty receiver");
            _setDefaultRoyalty(_royaltyReciever, _royaltyNumerator);
        }
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

    /**
     * @notice set the royalty for the specified token.
     * @param tokenId tokenId that you want to reset its royalty.
     * @param receiver the wallet address that receives the royalty.
     * @param feeNumerator the numerator of the token royalty which denumerator is 10000.
     * @notice you must be the owner of the contract and also owner of the token.
     */
    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) public onlyOwner {
        require(msg.sender == ownerOf(tokenId), "Collection: you must be the owner of the token to set the royalty");
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @notice Delete default royalty of Collection tokens.
     * @notice It can't be set again after that was removed.
     * @notice only owner of the contract can call this function.
     */
    function deleteDefaultRoyalty() public onlyOwner {
        _deleteDefaultRoyalty();
    }

    /**
     * @notice reset the royalty of the specified token.
     * @param tokenId tokenId that you want to reset its royalty.
     * @notice only owner of the contract can call this function.
     */
    function resetTokenRoyalty(uint256 tokenId) public onlyOwner {
        _resetTokenRoyalty(tokenId);
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