// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../0_diamond/libraries/LibDiamond.sol";
import "../1_ERC721SolidState/base/ERC721BaseInternal.sol";
import "./TagInternal.sol";

contract Tag is ERC721BaseInternal, TagInternal {

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    function init() public {
        _setPowerNumerator(10 ** 10);
        _setMinValue(10 ** 18);
        _setMinValue(10 ** 17);
    }

    function userPower(address userAddr) public view returns(uint256) {
        return _userPower(userAddr);
    }

    function totalPower() public view returns(uint256) {
        return _totalPower();
    }

    function tag(string calldata  notion) public payable {
        uint256 paidAmount = msg.value;
        address userAddr = msg.sender;

        uint256 tokenId = _nextTokenId();
        
        _safeMint(userAddr, tokenId);

        _newTag(userAddr, tokenId, notion, paidAmount, 0, block.number);
    }

    function levelup(
        uint256 tokenId,
        string memory mention
    ) public payable {
        _levelup(
            tokenId,
            _ownerOf(tokenId),
            msg.value,
            mention
        );
    }

    function setNotification(
        string memory notification1,
        string memory notification2
    ) public onlyOwner {
        _setNotification(notification1, notification2);
    }

    function setMinValue(uint256 amount) public onlyOwner {
        _setMinValue(amount);
    }

    function setMinLevelup(uint256 amount) public onlyOwner {
        _setMinLevelup(amount);
    }

    function contractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 amount, address receiver) public onlyOwner {
        payable(receiver).transfer(amount);
    }
}