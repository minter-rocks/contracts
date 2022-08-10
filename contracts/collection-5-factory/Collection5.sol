// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**                                   .----------------. 
 *                                   | .--------------. |
 *                                   | |  _______     | |
 *                                   | | |_   __ \    | |
 *                                   | |   | |__) |   | |
 *                                   | |   |  __ /    | |
 *                                   | |  _| |  \ \_  | |
 *                                   | | |____| |___| | |
 *                                   | |              | |
 *                                   | '--------------' |
 *                                   '------------------' 
 *
 *   ███╗   ███╗██╗███╗   ██╗████████╗███████╗██████╗    ██████╗  ██████╗  ██████╗██╗  ██╗███████╗
 *   ████╗ ████║██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗   ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝
 *   ██╔████╔██║██║██╔██╗ ██║   ██║   █████╗  ██████╔╝   ██████╔╝██║   ██║██║     █████╔╝ ███████╗
 *   ██║╚██╔╝██║██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗   ██╔══██╗██║   ██║██║     ██╔═██╗ ╚════██║
 *   ██║ ╚═╝ ██║██║██║ ╚████║   ██║   ███████╗██║  ██║██╗██║  ██║╚██████╔╝╚██████╗██║  ██╗███████║
 *   ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝
 */

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./ERC1155Capped.sol";
import "./ERC1155Royalty.sol";

/**
 * @title Collection contract version_2 ERC1155 
 * @notice every token id has a cap which owner of the contract sets.
 * @notice totalSupply of each id can be maximum of the cap.
 * @notice every tokenId has a uri which can be set by the owner.
 * @notice newId and safeMint restricted to the owner.
 * @notice the owner has to create newId befor they can mint on that Id.
 * @notice there is a default royalty which can be set once at initializing time and 
 * also every tokenId can have its particular royalty instead of default royalty.
 * @notice owner of the contract can delete default royalty and token royalties or set 
 * tokenRoyalty only when the token supply is zero.
 */
contract Collection5 is 
    Initializable, 
    OwnableUpgradeable, 
    ERC1155Burnable, 
    ERC1155URIStorage, 
    ERC1155Capped,
    ERC1155Royalty 
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
     * @param id tokenId that you want to reset its royalty.
     * @param receiver the wallet address that receives the royalty.
     * @param feeNumerator the numerator of the token royalty which denumerator is 10000.
     * @notice you must be the owner of the contract and also owner of the token.
     */
    function setTokenRoyalty(
        uint256 id,
        address receiver,
        uint96 feeNumerator
    ) public onlyOwner {
        require(!exists(id), "non-zero supply");
        _setTokenRoyalty(id, receiver, feeNumerator);
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
        override(ERC1155, ERC1155URIStorage)
        returns (string memory) 
    {
        return super.uri(tokenId);
    }

    function _mint(
        address account, 
        uint256 id, 
        uint256 amount, 
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Capped) {
        super._mint(account, id, amount, data);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(
        ERC1155, 
        ERC1155Royalty 
    ) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual override(ERC1155, ERC1155Royalty) {
        super._burn(from, id, amount);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual override(ERC1155, ERC1155Royalty) {
        super._burnBatch(from, ids, amounts);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}