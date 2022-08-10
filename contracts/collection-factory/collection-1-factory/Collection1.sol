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

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721RoyaltyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/**
 * @title NFT Collection contract version_1
 * @notice totalSupply is unlimited.
 * @notice token URIs are Basically different.
 * @notice safeMint restricted to the owner.
 * @notice safeMint can be auto increment tokenId or owner of the contract can choose the tokenId.
 * @notice there is a default royalty which can be set once at initializing time and 
 * also every token can have its particular royalty and does not use default royalty.
 * @notice owner of the contract can delete default royalty and token royalties and only 
 * set royalty for a specific token if they own it.
 */
contract Collection1 is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, ERC721BurnableUpgradeable, ERC721RoyaltyUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;

    /**
     * @notice creator of the collection.
     */
    string public _creator_;

    /**
     * @notice change the creator name.
     * @param _creatorName new name of the creator.
     * @notice only owner of the contract can call this function.
     */
    function setCreatorName(string memory _creatorName) public onlyOwner {
        _creator_ = _creatorName;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    /**
     * @notice initialize the collection called by the Factory.
     * @dev can be called only one time.
     * @param _creator creator of the collection.
     * @param _name name of collection tokens.
     * @param _symbol symbol of collection tokens.
     * @param _owner address of the creator of the collection.
     * @param _royaltyNumerator the numerator of default token royalties which denumerator is 10000.
     * @param _royaltyReciever the wallet address that receives the royalty.
     */
    function initialize(
        string memory _creator,
        string memory _name, 
        string memory _symbol,
        address _owner,
        uint96 _royaltyNumerator,
        address _royaltyReciever
    ) initializer public {
        _creator_ = _creator;
        __ERC721_init(_name, _symbol);
        __ERC721URIStorage_init();
        __ERC721Burnable_init();
        __Ownable_init(_owner);
        if (_royaltyNumerator > 0) {
            require(_royaltyReciever != address(0), "Collection: Invalid Royalty receiver");
            _setDefaultRoyalty(_royaltyReciever, _royaltyNumerator);
        }
    }

    /**
     * @notice mint a new token.
     * @param to address that will own the token.
     * @param tokenId desired id selected for the token.
     * @param uri uri of the token.
     * @dev the tokenId should be not minted before.
     * @notice only owner of the contract can call this function.
     */
    function safeMint(
        address to, 
        uint256 tokenId, 
        string memory uri
    ) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     * @notice mint a new token.
     * @param to address that will own the token.
     * @param uri uri of the token.
     * @dev the tokenId will be earned automatically.
     * @notice only owner of the contract can call this function.
     */
    function safeMint(
        address to, 
        string memory uri
    ) public onlyOwner {
        uint256 tokenId;
        do {
            tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
        } while (_exists(tokenId));

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
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
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    /**
     * @notice Delete default royalty of collection tokens.
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

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable, ERC721RoyaltyUpgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721RoyaltyUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}