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
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/**
 * @title NFT Collection contract version_3
 * @notice the contract is ERC721 enumerable.
 * @notice tokenIds are starting from 0 to (maxSupply - 1).
 * @notice tokenURIs are all in the same format baseURI/tokenId.
 * @notice totalSupply is limited but can be set by the owner.
 * @notice safeMint by auto increment only.
 * @notice safeMint public and payable and mintFee increases by the tokenId.
 * @notice there is a default royalty which can be set once at initializing time.
 * @notice the contract receives royalties.
 * @notice owner of the contract can delete default royalty.
 * @notice every one can log a comment in the contract but the comment fee varies for token owners.
 */
contract Collection is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721BurnableUpgradeable, ERC721RoyaltyUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;

    /**
     * @notice creator of the Collection.
     */
    string public _creator_;

    event SetCreatorName(string _creatorName);
    /**
     * @notice change the creator name.
     * @param _creatorName new name of the creator.
     * @notice only owner of the contract can call this function.
     */
    function setCreatorName(string memory _creatorName) public onlyOwner {
        _creator_ = _creatorName;
        emit SetCreatorName(_creatorName);
    }

    /**
     * @notice the base URI of the collection on IPFS.
     */
    string private _baseURI_;

    event SetBaseURI(string baseURI_);
    /**
     * @notice change the baseURI.
     * @param baseURI_ base URI of the tokens.
     * @notice only owner of the contract can call this function.
     */
    function setBaseURI(string memory baseURI_) public onlyOwner {
        _baseURI_ = baseURI_;
        emit SetBaseURI(baseURI_);
    }

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

    event SetMaxSupply(uint256 _maxSupply);
    /**
     * @notice change the maximum Supply.
     * @param _maxSupply new maximum Supply.
     * @notice only owner of the contract can call this function.
     * @notice the new maximum Supply must be greater than or equal to the current supply.
     */
    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        require(_maxSupply >= _tokenIdCounter.current(), "Collection: maxSupply must be greater than or equal to the current supply.");
        maxSupply = _maxSupply;
        emit SetMaxSupply(_maxSupply);
    }


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice initialize the Collection called by the Factory.
     * @dev can be called only one time.
     */
    function initialize() initializer public {
        _creator_ = "Renope"; //creator of the Collection.
        __ERC721_init("collection3", "c3");
        __ERC721Enumerable_init();
        __ERC721Burnable_init();
        __Ownable_init(msg.sender);
        _baseURI_ = ""; //the base uRI of the collection on IPFS.
        maxSupply = 100; //maximum number of tokens can be minted.
        _setDefaultRoyalty(address(this), 500);
        baseMintFee = 0.05 * 10 ** 18; //the base fee required to mint the first token.
        mintFeeRatioNumerator = 200; //the numerator of mint fee ratio which denumerator is 10000.
        tokenHoldersCommentFee = 0.005 * 10 ** 18; //comment fee for the token holders.
        guestsCommentFee = 0.01 * 10 ** 18; //comment fee for regular people.
    }

    mapping(address => string) users;
    mapping(string => address) registered;

    event Register(address _userAddr, string username);
    /**
     * @notice set a username on your wallet address.
     * @param _username the new username you set.
     * @notice you cannot use preselected usernames.
     */
    function register(string memory _username) public {
        require(registered[_username] == address(0), "Collection: the username has already been registered");
        users[msg.sender] = _username;
        emit Register(msg.sender, _username);
    }

    event UnRegister(address _userAddr);
    /**
     * @notice delete your username.
     */
    function unRegister() public {
        delete registered[users[msg.sender]];
        delete users[msg.sender];
        emit UnRegister(msg.sender);
    }

    /**
     * @notice returns the username of the specified address.
     */
    function username(address userAddr) public view returns(string memory) {
        return users[userAddr];
    }

    /**
     * @notice returns the username of the specified tokenId's owner.
     */
    function ownerName(uint256 tokenId) public view returns(string memory) {
        return username(ownerOf(tokenId));
    }

    /**
     * @notice returns token balance of the specified _username.
     */
    function userBalance(string memory _username) public view returns(uint256) {
        return balanceOf(registered[_username]);
    }


    uint256 baseMintFee;
    function setBaseMintFee(uint256 _baseMintFee) public onlyOwner {
        baseMintFee = _baseMintFee;
    }
    
    uint256 mintFeeRatioNumerator;
    function setMintFeeRatioNumerator(uint256 _mintFeeRatioNumerator) public onlyOwner {
        mintFeeRatioNumerator = _mintFeeRatioNumerator;
    }
    
    /**
     * @notice returns required fee to mint the next token.
     */
    function mintBatchFee(uint256 tokenOffset, uint256 numberOfTokens) public view returns(uint256) {
        return numberOfTokens * mintFee(tokenOffset + numberOfTokens / 2);
    }
    
    /**
     * @notice returns required fee to mint the next token.
     */
    function mintFee(uint256 tokenIndex) public view returns(uint256) {
        return baseMintFee + (baseMintFee * tokenIndex * mintFeeRatioNumerator / 10000 );
    }

    /**
     * @notice mint a new token.
     * @param to address that will own the token.
     * @dev the tokenId will be earned automatically.
     * @notice only owner of the contract can call this function.
     */
    function safeMintBatch(address to, uint256 numberOfTokens) public payable {
        require(msg.value >= mintBatchFee(_tokenIdCounter.current(), numberOfTokens), "Collection: insufficient mint fee");
        for(uint256 index; index < numberOfTokens; index++) {
            _safeMint(to, _tokenIdCounter.current());
            _tokenIdCounter.increment();
        }
    }

    /**
     * @notice mint a new token.
     * @param to address that will own the token.
     * @dev the tokenId will be earned automatically.
     * @notice only owner of the contract can call this function.
     */
    function safeMint(address to) public payable {
        uint256 tokenId = _tokenIdCounter.current();
        require(msg.value >= mintFee(tokenId), "Collection: insufficient mint fee");
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    /**
     * @notice override mint function to change functionality.
     * @notice tokenIds limited to maxSupply.
     */
    function _mint(address to, uint256 tokenId) internal override {
        require (tokenId < maxSupply, "Collection: Invalid token Id");
        super._mint(to, tokenId);
    }

    function safeTransferFromBatch(
        address[] memory from,
        address[] memory to,
        uint256[] memory tokenId
    ) public {
        require(from.length == tokenId.length && to.length == tokenId.length, "Collection: you must enter same length arrays");
        for(uint256 index; index < tokenId.length; index++) {
            safeTransferFrom(from[index], to[index], tokenId[index]);
        }
    }

    function burnBatch(uint256[] memory tokenId) public {
        for(uint256 index; index < tokenId.length; index++) {
            burn(tokenId[index]);
        }
    }

    mapping(address => uint256) userPaidValue;

    uint256 public tokenHoldersCommentFee;
    function setTokenHoldersCommentFee(uint256 _tokenHoldersCommentFee) public onlyOwner {
        tokenHoldersCommentFee = _tokenHoldersCommentFee;
    }

    uint256 public guestsCommentFee;
    function setGuestsCommentFee(uint256 _guestsCommentFee) public onlyOwner {
        guestsCommentFee = _guestsCommentFee;
    }

    uint256 public commentIndex;

    event Comment(address userAddr, uint256 userBalance, uint256 paidAmount, string text, uint256 typeInt, uint256 _commentIndex);
    /**
     * @notice comments as event.
     */
    function comment(string memory text, uint256 typeInt) public payable {
        uint256 _userBalance = balanceOf(msg.sender);
        uint256 paidAmount = msg.value;
        if(_userBalance > 0){
            require(paidAmount > tokenHoldersCommentFee, "Collection: insufficient fee for tokenHolders.");
        } else {
            require(paidAmount > tokenHoldersCommentFee, "Collection: insufficient fee for guest.");
        }
        userPaidValue[msg.sender] += paidAmount;
        emit Comment(msg.sender, _userBalance, paidAmount, text, typeInt, commentIndex);
        commentIndex++;
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
     * @notice withdraw specified amount of ETH from contract.
     * @notice only owner of the contract can call this funcion.
     */
    function withdraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    
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