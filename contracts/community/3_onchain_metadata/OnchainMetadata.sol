// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../1_ERC721SolidState/base/ERC721BaseInternal.sol";
import "../2_tag/TagStorage.sol";
import '@solidstate/contracts/utils/AddressUtils.sol';
import '@solidstate/contracts/utils/UintUtils.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import "./utils/UintToFloatString.sol";
import "./utils/SVGTextValidator.sol";

contract OnchainMetadata is ERC721BaseInternal {
    using AddressUtils for address;
    using UintUtils for uint;
    using UintToFloatString for uint;
    using ERC721BaseStorage for ERC721BaseStorage.Layout;

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        require(ERC721BaseStorage.layout().exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        TagStorage.Layout storage l = TagStorage.layout();
        TagStorage.Tag memory d = TagStorage.layout().tags[tokenId];

        uint256 votingPower = d.votingPower;

        string memory image =_image({
            notion1 : SVGTextValidator.validate(d.notion1),
            notion2 : SVGTextValidator.validate(d.notion2),
            cardPower : votingPower.floatString(18, 3),
            notification1 : l.notification1,
            notification2 : bytes(l.notification2).length > 0 ? l.notification2 : 
            string.concat('First Goal : ',l.totalValue.floatString(18, 2),' of 8000 MATIC'),
            blockNumber : d.blockNumber.toString(),
            valueMatic : d.amount_MATIC.floatString(18, 2),
            points : _points(uint256(keccak256(abi.encodePacked(d.notion1, d.amount_MATIC))), votingPower)
        });

        return string.concat('data:application/json;base64,', Base64.encode(abi.encodePacked(
              '{"name": "#', tokenId.toString(), 
            '", "description": "', d.notion1, ' ', d.notion2,
            '", "image": "', image,
            '", "interaction" : {"read":[],"write":[{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"changePattern","outputs":[],"stateMutability":"nonpayable","type":"function"}]}}'
            ))
        ); 
    }

    function _image(
        string memory notion1,
        string memory notion2,
        string memory cardPower,
        string memory notification1,
        string memory notification2,
        string memory blockNumber,
        string memory valueMatic,
        string memory points
    ) private pure returns(string memory) {      
        string memory imageString = string.concat(
            '<?xml version="1.0" encoding="utf-8"?><svg viewBox="200 0 600 1000" xmlns="http://www.w3.org/2000/svg"><defs><clipPath id="clip-path" transform="translate(78.35 72.9)"><rect class="cls-1" width="195.23" height="265.56"/></clipPath><style>.cls-1,.cls-9{fill:none;}.cls-2{clip-path:url(#clip-path);}.cls-3{stroke:#1d1d1b;}.cls-3,.cls-9{stroke-miterlimit:10;}.cls-14,.cls-4,.cls-6,.cls-7,.cls-8{font-size:10px;}.cls-11,.cls-14,.cls-4{fill:#99cf29;}.cls-11,.cls-13,.cls-4,.cls-5,.cls-6,.cls-7,.cls-8{font-family:CourierNewPS-BoldMT, Courier New;font-weight:700;}.cls-5{font-size:12px;}.cls-13,.cls-5{fill:#fff;}.cls-6{fill:#a80054;}.cls-12,.cls-7{fill:#dd6400;}.cls-8{fill:#00e1f2;}.cls-9{stroke:#dadada;stroke-width:1px;}.cls-10{fill:#1b1718;opacity:0.98;}.cls-11{font-size:14px;}.cls-13{font-size:9px;}.cls-14{font-family:CourierNewPSMT,font-size: 10px, Courier New;}</style></defs><g class="cls-2" transform="matrix(3.073298, 0, 0, 3.765627, -40.792856, -274.514233)"><rect class="cls-3" x="78.35" y="72.9" width="195.23" height="265.14"/><text class="cls-4" style=" font-size: 10px;" x="88.111" y="273.1">Voting</text><text class="cls-5" style=" font-size: 12px;" x="88.111" y="236.5" transform="matrix(0.922287, 0, 0, 1, 6.847331, 0)">',
            valueMatic, 
            ' MATIC</text><text class="cls-6" style=" font-size: 10px;" x="162.95" y="257.92">',
            blockNumber,
            '</text><text class="cls-7" style=" font-size: 10px;" x="88.111" y="257.92">Block</text><text class="cls-7" style=" font-size: 10px;" x="129.11" y="273.1">Power</text><text class="cls-8" style=" font-size: 10px;" x="122.602" y="257.92">number</text></g><polyline class="cls-9" points="',
            points,
            '"/><g class="cls-2" transform="matrix(3.073298, 0, 0, 3.765627, -40.792856, -274.514233)"><rect class="cls-10" x="78.35" y="72.9" width="195.23" height="53.112"/><rect class="cls-10" x="78.35" y="285.348" width="195.23" height="53.112"/><text class="cls-11" x="88.111" y="94.59">Minter.<tspan class="cls-12" x="146.921" y="94.59" style="font-size: 14px; word-spacing: 0px;">rocks</tspan></text><text class="cls-8" style=" font-size: 10px;" x="164.902" y="273.1">',
            cardPower,
            '</text><text class="cls-13" x="88.111" y="112">',
            notion1,
            '<tspan x="88.111" y="123">',
            notion2,
            '</tspan></text><text class="cls-14" x="0" y="-5" transform="matrix(0.813628, 0, 0, 1.01345, 91.365326, 304.546661)" style="fill: rgb(118, 150, 44); paint-order: fill;">notification</text><text class="cls-14" x="0" y="-10" transform="matrix(0.994492, 0, 0, 1, 88.111488, 322.839996)">',
            notification1,
            '<tspan x="0" y="5">',
            notification2,
            '</tspan></text></g></svg>'
        );
        
        return string.concat('data:image/svg+xml;base64,', Base64.encode(abi.encodePacked(imageString)));
    }

    function _points(uint256 hashNum, uint256 cardPower) private pure returns(string memory points) {
        cardPower = cardPower / 10 ** 18;
        uint256 numPoints;
        while (cardPower >= 10) {
            cardPower /= 10;
            numPoints ++;
        }
        numPoints = 10 * numPoints + cardPower;
        while(numPoints > 0) {
            if(hashNum > 1000) {
                points = string.concat(
                    points,
                    ((hashNum /= 10) % 1000).toString(),
                    " "
                );
                numPoints--;
            }
        }
    }
}