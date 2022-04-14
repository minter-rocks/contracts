// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library UintQueue {
    struct Queue {
        uint128 start;
        uint128 end;
        mapping(uint128 => uint256) items;
    }

    function _length(Queue storage queue) internal view returns(uint256) {
        return queue.end - queue.start;
    }

    function _enqueue(Queue storage queue, uint256 item) internal {
        queue.items[queue.end++] = item;
    }

    function _dequeue(Queue storage queue) internal returns (uint256) {
        assert(_length(queue) > 0);
        uint256 item = queue.items[queue.start];
        queue.items[queue.start++] = 0;
        return item;
    }
}