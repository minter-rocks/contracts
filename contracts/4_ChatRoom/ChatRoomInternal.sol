// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ChatRoomStorage.sol";
import "./utils/StringUtil.sol";
import "./utils/LiteralRegex.sol";

contract ChatRoomInternal {
    using ChatRoomStorage for ChatRoomStorage.Layout;
    using StringUtil for string;
    using LiteralRegex for string;

    event Comment(
        string username_, 
        address indexed userAddr, 
        uint256 userPower, 
        uint256 paidAmount, 
        string text, 
        uint256 indexed typeInt, 
        uint256 commentIndex_
    );
    event Register(address userAddr, string username);
    event UnRegister(address _userAddr);

    function _registered(string memory username_) internal view returns(bool) {
        return ChatRoomStorage.layout().registered[username_.lower()] != address(0);
    }

    function _register(address userAddr, string memory username_) public {
        ChatRoomStorage.Layout storage l = ChatRoomStorage.layout();

        require(
            username_.isLiteral(),
            "you can just use numbers(0-9) letters(a-zA-Z) and signs(-._)"
        );

        string memory lower = username_.lower();

        require(
            l.registered[lower] == address(0), 
            "ChatRoomInternal: the username has already been registered"
        );

        l.users[userAddr] = username_;
        l.registered[lower] = userAddr;

        emit Register(userAddr, username_);
    }

    /**
     * @notice delete your username.
     */
    function _unRegister(address userAddr) public {
        ChatRoomStorage.Layout storage l = ChatRoomStorage.layout();
        delete l.registered[l.users[userAddr].lower()];
        delete l.users[userAddr];
        emit UnRegister(userAddr);
    }

    /**
     * @notice returns the username of the specified address.
     */
    function _username(address userAddr) public view returns(string memory) {
        return ChatRoomStorage.layout().users[userAddr];
    }

    function _comment(
        address userAddr,
        uint256 userPower,
        uint256 paidAmount,
        string memory text,
        uint256 typeInt
    ) internal {

        if(userPower == 0){
            require(
                paidAmount > ChatRoomStorage.layout().guestCommentFee,
                "Collection: insufficient fee for guest."
            );
        }

        emit Comment(
            _username(userAddr),
            userAddr, 
            userPower, 
            paidAmount, 
            text, 
            typeInt, 
            ChatRoomStorage.layout().commentIndex++
        );
    }

    function _setGuestCommentFee(uint256 commentFee) internal {
        ChatRoomStorage.layout().guestCommentFee = commentFee;
    }
}