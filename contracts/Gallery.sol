// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721RoyaltyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/**
 * @title NFT Gallery contract
 */
contract Gallery is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, ERC721BurnableUpgradeable, ERC721RoyaltyUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;

    /**
     * @notice creator of the gallery.
     */
    string public _creator_;

    /**
     * @notice change the creator name.
     * @param _creatorName new name of the creator.
     * @dev only owner of the contract can call this function.
     */
    function setCreatorName(string memory _creatorName) public onlyOwner {
        _creator_ = _creatorName;
    }

    /**
     * @notice initialize the gallery called by the Factory.
     * @dev can be called only one time.
     * @param _creator creator of the gallery.
     * @param _name name of gallery tokens.
     * @param _symbol symbol of gallery tokens.
     * @param _owner address of the creator of the gallery.
     * @param _royaltyNumerator the numerator of default token royalties which denumerator
     * is 10000.
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
            require(_royaltyReciever != address(0), "Gallery: Invalid Royalty receiver");
            _setDefaultRoyalty(_royaltyReciever, _royaltyNumerator);
        }
    }

    function safeMint(
        address to, 
        string memory uri
    ) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function safeMintAndSetRoyalty(
        address to, 
        string memory uri,
        uint96 royaltyNumerator,
        address _royaltyReciever
    ) public onlyOwner {
        safeMint(to, uri);
        if (royaltyNumerator > 0) {
            require(_royaltyReciever != address(0), "Gallery: Invalid Royalty receiver");
            _setDefaultRoyalty(_royaltyReciever, royaltyNumerator);
        }
    }


    function deleteDefaultRoyalty() public onlyOwner {
        _deleteDefaultRoyalty();
    }

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