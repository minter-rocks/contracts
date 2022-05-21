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
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721RoyaltyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/**
 * @title NFT Collection contract version_2
 * @notice the contract is ERC721 enumerable.
 * @notice tokenIds are starting from 0 to (maxSupply - 1).
 * @notice tokenURIs are all in the same format baseURI/tokenId.
 * @notice totalSupply is limited but can be set by the owner.
 * @notice safeMint public and payable.
 * @notice safeMint by auto increment only.
 * @notice there is a default royalty which can be set once at initializing time.
 * @notice the contract receives royalties.
 * @notice owner of the contract can delete default royalty.
 * @notice every token owner can log a comment in the contract by its token and address.
 */
contract Collection is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721BurnableUpgradeable, ERC721RoyaltyUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;

    /**
     * @notice creator of the Collection.
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

    /**
     * @notice the base uri of the collection on IPFS.
     */
    string private _baseURI_;

    /**
     * @notice override -baseURI function to define functionality.
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseURI_;
    }

    /**
     * @notice maximum number of tokens can be minted.
     */
    uint256 public maxSupply;

    /**
     * @notice change the maximum Supply.
     * @param _maxSupply new maximum Supply.
     * @notice only owner of the contract can call this function.
     * @notice the new maximum Supply must be greater than or equal to the current supply.
     */
    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        require(_maxSupply >= _tokenIdCounter.current(), "Collection: maxSupply must be greater than or equal to the current supply.");
        maxSupply = _maxSupply;
    }


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice initialize the Collection called by the Factory.
     * @dev can be called only one time.
     * @param _creator creator of the Collection.
     * @param _name name of Collection tokens.
     * @param _symbol symbol of Collection tokens.
     * @param _uri the base uri of the collection on IPFS.
     * @param _maxSupply maximum number of tokens can be minted.
     * @param _owner address of the creator of the Collection.
     * @param _royaltyNumerator the numerator of default token royalties which denumerator is 10000.
     */
    function initialize(
        string memory _creator,
        string memory _name, 
        string memory _symbol,
        string memory _uri,
        uint256 _maxSupply,
        address _owner,
        uint96 _royaltyNumerator
    ) initializer public {
        _creator_ = _creator;
        __ERC721_init(_name, _symbol);
        __ERC721Enumerable_init();
        __ERC721Burnable_init();
        __Ownable_init(_owner);
        _baseURI_ = _uri;
        maxSupply = _maxSupply;
        if (_royaltyNumerator > 0) {
            _setDefaultRoyalty(address(this), _royaltyNumerator);
        }
    }

    uint256 baseMintFee;
    function setBaseMintFee(uint256 _baseMintFee) public onlyOwner {
        baseMintFee = _baseMintFee;
    }
    
    uint256 mintFeeRatioNumerator;
    function setMintFeeRatioNumerator(uint256 _mintFeeRatioNumerator) public onlyOwner {
        mintFeeRatioNumerator = _mintFeeRatioNumerator;
    }
    
    function mintFee() public view returns(uint256) {
        return baseMintFee + (_tokenIdCounter.current() * mintFeeRatioNumerator / 10000 );
    }

    /**
     * @notice mint a new token.
     * @param to address that will own the token.
     * @dev the tokenId will be earned automatically.
     * @notice only owner of the contract can call this function.
     */
    function safeMint(address to) public payable {
        require(msg.value >= mintFee(), "Collection: insufficient mint fee");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
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
     * @notice override mint function to change functionality.
     * @notice tokenIds limited to maxSupply.
     */
    function _mint(address to, uint256 tokenId) internal override {
        require (tokenId < maxSupply, "Collection: Invalid token Id");
        super._mint(to, tokenId);
    }

    event Comment(uint256 indexed tokenId, address userAddr, string text);
    /**
     * @notice comments as event.
     */
    function comment(uint256 tokenId, string memory text) public {
        require(msg.sender == ownerOf(tokenId), "Collection: Invalid token Id");
        emit Comment(tokenId, msg.sender, text);
    }


    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721RoyaltyUpgradeable)
    {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721RoyaltyUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}