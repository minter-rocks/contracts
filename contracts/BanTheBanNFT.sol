// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./extensions/ERC721CreationRecord.sol";
import "./BTBArchive.sol";
import "./libraries/UintQueue.sol";

contract BanTheBanNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Royalty, AccessControl, ERC721CreationRecord {
    using Counters for Counters.Counter;
    using UintQueue for UintQueue.Queue;

    uint256 public maxSupply;

    bytes32 public constant MINTER_ACCESS = keccak256("MINTER_ACCESS");
    bytes32 public constant BURNER_ACCESS = keccak256("BURNER_ACCESS");
    bytes32 public constant SUPPLY_ACCESS = keccak256("SUPPLY_ACCESS");
    bytes32 public constant ROYALTY_ACCESS = keccak256("ROYALTY_ACCESS");
    bytes32 public constant ARCHIVE_ACCESS = keccak256("ARCHIVE_ACCESS");

    Counters.Counter private _tokenIdCounter;
    UintQueue.Queue private _burnedIds;

    constructor() ERC721("BanTheBanNFT", "BTB") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ACCESS, msg.sender);
        _grantRole(BURNER_ACCESS, msg.sender);
        _grantRole(SUPPLY_ACCESS, msg.sender);
        _grantRole(ROYALTY_ACCESS, msg.sender);
        _grantRole(ARCHIVE_ACCESS, msg.sender);
        maxSupply = 100;
    }

    uint256 private _mintFee;
    function mintFee() public view returns(uint256) {
        return _mintFee;
    }
    function setMintFee(uint256 mintFee_) public onlyRole(MINTER_ACCESS) {
        _mintFee = mintFee_;
    }

    function safeMintBatch(address[] memory to, string[] memory uri) public payable {
        require(msg.value >= mintFee() * uri.length, "BanTheBanNFT: insufficient mint fee");
        uint256 tokenId;
        for (uint256 i = 0; i < uri.length; i++) {
            tokenId = _nextAvailableId();
            _safeMint(to[i], tokenId);
            _setTokenURI(tokenId, uri[i]);
        }
    }

    function safeMint(address to, string memory uri) public payable {
        require(msg.value >= mintFee(), "BanTheBanNFT: insufficient mint fee");
        uint256 tokenId = _nextAvailableId();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _nextAvailableId() private returns(uint256 _Id) {
        if(_burnedIds._length() > 0){
            _Id = _burnedIds._dequeue();
        } else {
            require(_tokenIdCounter.current() < maxSupply, "maxSupply filled");
            _Id = _tokenIdCounter.current();
            _tokenIdCounter.increment();
        }
    }

    function burn(uint256 tokenId) public virtual onlyRole(BURNER_ACCESS) {
        _burn(tokenId);
        _burnedIds._enqueue(tokenId);
    }

    BanTheBanArchive BTBArchive = new BanTheBanArchive();

    function archiveToken(uint256 tokenId) public virtual onlyRole(ARCHIVE_ACCESS) {
        BTBArchive.safeMint(ownerOf(tokenId), tokenId, tokenURI(tokenId));
        _burn(tokenId);
    }

    function unarchiveToken(uint256 tokenId) public virtual onlyRole(ARCHIVE_ACCESS) {
        _safeMint(BTBArchive.ownerOf(tokenId), tokenId);
        _setTokenURI(tokenId, BTBArchive.tokenURI(tokenId));
        BTBArchive.burn(tokenId);
    }

    function adjustMaxSupply(uint256 _maxSupply) public virtual onlyRole(SUPPLY_ACCESS) {
        require(_maxSupply >= _tokenIdCounter.current(), "BanTheBanNFT: Enter a number greater than current supply.");
        maxSupply = _maxSupply;
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public virtual onlyRole(ROYALTY_ACCESS) {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function deleteDefaultRoyalty() public virtual onlyRole(ROYALTY_ACCESS) {
        _deleteDefaultRoyalty();
    }

    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) public virtual {
        require(msg.sender == creatorOf(tokenId), "BanTheBanNFT: only creator of the token can set Royalty");
        require(feeNumerator <= 1000, "BanTheBanNFT: token royalty can be set up to 10 percent");
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    function resetTokenRoyalty(uint256 tokenId) public virtual {
        require(msg.sender == creatorOf(tokenId), "BanTheBanNFT: only creator of the token can set Royalty");
        _resetTokenRoyalty(tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable, ERC721CreationRecord)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage, ERC721Royalty) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}