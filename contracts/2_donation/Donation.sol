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


    function donate(string memory tag) public payable {
        uint256 paidAmount = msg.value;
        require(
            paidAmount >= 10 ** 18,
            "Donation: minimum donation is 1 MATIC."
        );
        require(
            bytes(tag).length < 40,
            "Donation: please insert a tag lesser than 40 characters."
        );
        uint256 tokenId = _nextTokenId();
        _safeMint(msg.sender, tokenId);

        _newDonation(tokenId, tag, paidAmount, _IN_USD_18(paidAmount), block.number);
    }

    function newNotification(string memory notification) public onlyOwner {
        _newNotification(notification);
    }

}