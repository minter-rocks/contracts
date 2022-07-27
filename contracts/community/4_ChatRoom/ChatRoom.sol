// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "../0_diamond/libraries/LibDiamond.sol";
import "../2_donation/DonationInternal.sol";
import "./ChatRoomInternal.sol";

contract ChatRoom is DonationInternal, ChatRoomInternal{

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    function registered(string memory username_) public view returns(bool) {
        return _registered(username_);
    }

    function register(string memory username_) public {
        _register(msg.sender, username_);
    }    
    
    function unRegister() public {
        _unRegister(msg.sender);
    }

    function username(address userAddr) public view returns(string memory usename_) {
        usename_ = _username(userAddr);
        require(bytes(usename_).length > 0, "ChatRoom: query for not registered user");
    }

    function comment(string memory text, uint256 typeInt) public payable {
        _comment({
            userAddr : msg.sender, 
            userPower : _userPower(msg.sender), 
            paidAmount : msg.value, 
            text : text, 
            typeInt : typeInt
        });
    }

    function setGuestCommentFee(uint256 commentFee) public onlyOwner {
        _setGuestCommentFee(commentFee);
    }
}