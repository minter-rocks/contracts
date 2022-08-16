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
    using SVGTextValidator for string;

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        TagStorage.Layout storage l = TagStorage.layout();
        TagStorage.Tag storage t = TagStorage.layout().tags[tokenId];

        require(t.blockNumber != 0, "ERC721Metadata: URI query for nonexistent token");

        uint256 votingPower = t.votingPower;

        string memory donates;
        for (uint256 i; i < t.donatesCount; i++){
            donates = string.concat(
                t.donates[i].donator.toString(),
                ", ",
                t.donates[i].amount.floatString(18, 3),
                ", ",
                t.donates[i].mention,
                " /n"
            );
        }
        (string memory notion1, string memory notion2) = convertTo2Lines(t.notion);

        string memory image =_image({
            notion1 : notion1.validate(),
            notion2 : notion2.validate(),
            cardPower : votingPower.floatString(18, 3),
            notification1 : l.notification1,
            notification2 : bytes(l.notification2).length > 0 ? l.notification2 : 
            string.concat('First Goal : ',l.totalValue.floatString(18, 2),' of 8000 MATIC'),
            blockNumber : t.blockNumber.toString(),
            value : t.value.floatString(18, 2),
            points : _points(uint256(keccak256(abi.encodePacked(t.notion, t.value))), votingPower),
            burned : t.value == 0
        });

        return string.concat('data:application/json;base64,', Base64.encode(abi.encodePacked(
              '{"name": "#', tokenId.toString(), 
            '", "description": "', donates,
            '", "image": "', image,
            '", "interaction" : {"read":[],"write":[{"inputs": [{"internalType": "uint256","name": "tokenId","type": "uint256"},{"internalType": "string","name": "mention","type": "string"}],"name": "levelup","outputs": [],"stateMutability": "payable","type": "function"},{"inputs": [{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "withdrawTag","outputs": [],"stateMutability": "nonpayable","type": "function"}]}}'
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
        string memory value,
        string memory points,
        bool burned
    ) private pure returns(string memory) {      
        string memory imageString = string.concat(
            '<?xml version="1.0" encoding="utf-8"?><svg viewBox="150 0 700 1000" xmlns="http://www.w3.org/2000/svg"><defs><filter id="motion-blur-duotone" color-interpolation-filters="sRGB" x="-500%" y="-500%" width="1000%" height="1000%"><feGaussianBlur stdDeviation="7 0" edgeMode="none"/><feColorMatrix type="matrix" result="grayscale" values="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0"/><feComponentTransfer result="duotone"><feFuncR type="table" tableValues="0.741 0.988"/><feFuncG type="table" tableValues="0.043 0.733"/><feFuncB type="table" tableValues="0.569 0.051"/><feFuncA type="table" tableValues="0 1"/></feComponentTransfer></filter><clipPath id="clip-path"><rect width="700" height="1000" x="150" y="0"/></clipPath><style>.cls-1{clip-path:url(#clip-path); font-family:Courier New;}.cls-2{stroke:#1d1d1b;}.cls-3{fill:none; stroke-miterlimit:10; stroke:#dadada;stroke-width:1px;}.cls-4{fill:#1b1718;opacity:0.97;}.cls-5{font-size: 70px;}.cls-6{font-size: 32px; fill:#fff; font-family:Courier New;}.cls-7{font-size: 50px; fill:#fff;}.cls-8{font-size: 35px;}.cls-9{font-size: 40px;}.cls-10{fill:#99cf29; font-size: 35px; font-family:CourierNewPSMT}</style></defs><g class="cls-1"',
            burned ?   ' style="filter: url(#motion-blur-duotone);"' : '',
            '><rect class="cls-2" x="150" y="0" width="700" height="1000"/><polyline class="cls-3" points="',
            points,
            '"/><rect class="cls-4" x="150" y="0" width="700" height="210"/><rect class="cls-4" x="150" y="800" width="700" height="200"/><text class="cls-5" x="180" y="95" style="fill:#99cf29;">Minter.<tspan style="fill:#dd6400;">rocks</tspan></text><text class="cls-6" x="180" y="155">',
            notion1,
            '<tspan x="180" y="195">',
            notion2,
            '</tspan></text><text class="cls-7" x="180" y="600">',
            value,
            ' Matic</text><text class="cls-8" x="180" y="685" style="fill:#dd6400;">Block<tspan style="fill:#00e1f2;"> number</tspan><tspan style="fill:#a80054;"> ',
            blockNumber,
            '</tspan></text><text class="cls-9" x="180" y="750" style="fill:#99cf29;">Voting <tspan style="fill:#dd6400;" >Power </tspan><tspan style="fill:#00e1f2;">',
            cardPower,
            '</tspan></text><text class="cls-10" x="185" y="850" >notification<tspan x="180" y="910" style="font-size: 30px;">',
            notification1,
            '<tspan  x="180" y="955">',
            notification2,
            '</tspan></tspan></text></g></svg>'
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
    function convertTo2Lines(string memory input) internal pure returns(
        string memory output1,
        string memory output2
    ) {
        bool line2;
        uint256 char;
        uint256 charAdd;
        uint256 len2;
        uint256 lineBreak;
        uint256 forceBreak;

        bytes memory inputBytes = bytes(input);

        while (char < inputBytes.length){
            if (inputBytes[char]>>7==0){
                charAdd = 1;
                len2 += 2;
            } else if (inputBytes[char]>>5==bytes1(uint8(0x6))){
                charAdd = 2;
                len2 += 2;
            } else if (inputBytes[char]>>4==bytes1(uint8(0xE))){
                charAdd = 3;
                len2 += 3;
            } else if (inputBytes[char]>>3==bytes1(uint8(0x1E))){
                charAdd = 4;
                len2 += 4;
            } else {
                //For safety
                charAdd = 1;
                len2 += 2;
            }

            if(!line2 && inputBytes[char] == 0x20){
                lineBreak = char+charAdd;
            }

            char += charAdd;

            if(len2 > 66){
                line2 = true;
                forceBreak = char-charAdd;
                len2 = 0;
            }
        }

        if(line2) {
            lineBreak = len2/2 < lineBreak ? lineBreak : forceBreak;
            bytes memory outBytes1 = new bytes(lineBreak);
            bytes memory outBytes2 = new bytes(char - lineBreak);
            for(uint8 i; i<lineBreak; i++){
                outBytes1[i] = inputBytes[i];
            }
            for(uint8 i; i<char-lineBreak; i++){
                outBytes2[i] = inputBytes[i + lineBreak];
            }

            output1 = string(outBytes1);
            output2 = string(outBytes2);
        } else {
            output1 = input;
        }
    }
}