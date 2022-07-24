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

        delete DonationStorage.layout().totalPower;

        for(uint i; i < 10; i++) {
            DonationStorage.layout().donates[i].votingPower /= 100;
            DonationStorage.layout().totalPower += DonationStorage.layout().donates[i].votingPower;
        }
    }

    function userPower(address userAddr) public view returns(uint256) {
        return _userPower(userAddr);
    }

    function totalPower() public view returns(uint256) {
        return _totalPower();
    }

    function donate(string memory tag) public payable {
        uint256 paidAmount = msg.value;
        require(
            bytes(tag).length < 20,
            "Donation: please insert a tag lesser than 20 characters."
        );
        uint256 tokenId = _nextTokenId();
        address userAddr = msg.sender;
        _safeMint(userAddr, tokenId);

        _newDonation(userAddr, tokenId, tag, paidAmount, _IN_USD_18(paidAmount), block.number);
    }

    function newNotification(string memory notification) public onlyOwner {
        _newNotification(notification);
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