// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../0_diamond/libraries/LibDiamond.sol";
import "../1_ERC721SolidState/base/ERC721BaseInternal.sol";
import "./DonationInternal.sol";
import "./utils/PriceFeed.sol";

contract Donation is ERC721BaseInternal, DonationInternal, PriceFeed {

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    function init() public {
        _setPowerNumenator(10 ** 10);
        _setMinDonation(10 ** 18);
    }

    function userPower(address userAddr) public view returns(uint256) {
        return _userPower(userAddr);
    }

    function totalPower() public view returns(uint256) {
        return _totalPower();
    }

    function donate(string calldata  tag) public payable {
        uint256 paidAmount = msg.value;
        address userAddr = msg.sender;

        uint256 tokenId = _nextTokenId();
        
        _safeMint(userAddr, tokenId);

        _newDonation(userAddr, tokenId, tag, paidAmount, _IN_USD_18(paidAmount), block.number);
    }

    function changePattern(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Donation: caller is not approved nor owner");
        _increaseNonce(tokenId);
    }

    function setNotification(
        string memory notification1,
        string memory notification2
    ) public onlyOwner {
        _setNotification(notification1, notification2);
    }

    function setMinDonation(uint256 amount) public onlyOwner {
        _setMinDonation(amount);
    }

    function contractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 amount, address receiver) public onlyOwner {
        payable(receiver).transfer(amount);
    }
}