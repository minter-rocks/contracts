// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../0_diamond/libraries/LibDiamond.sol";
import "../0_diamond/libraries/AppStorage.sol";
import '@solidstate/contracts/utils/AddressUtils.sol';
import '@solidstate/contracts/utils/UintUtils.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import "./utils/UintToFloatString.sol";
import "./utils/SVGTextValidator.sol";
import "../2_words/utils/StringUtils.sol";
import "./utils/TemplateView.sol";

contract OnchainMetadata is TemplateView {
    using AddressUtils for address;
    using UintUtils for uint;
    using UintToFloatString for uint;
    using SVGTextValidator for string;
    using StringUtils for *;

    function changeTokenTemplate(uint256 tokenId, uint256 templateId) public {
        AppStorage.WordInfo storage wi = AppStorage.layout().words[tokenId].info;
        require(msg.sender == wi.author, "OnchainMetadata: access to change template denied");
        wi.template = templateId;
    }

    function updateTemplate(
        uint256 templateId,
        address templateAddress,
        uint256 templatePrice,
        string calldata description,
        uint256[] calldata charCount
    ) public {
        AppStorage.Template storage template = AppStorage.layout().templates[templateId];
        require(
            template.contAddr == address(0) || template.creator == msg.sender,
            "OnchainMetadata: access to change template denied"
        );
        template.contAddr = templateAddress;
        template.creator = msg.sender;
        template.price = templatePrice;
        template.description = description;
        template.charCount = charCount;
    }

    // function uri(uint256 tokenId) public view returns(string memory) {
    //     return tokenURI(tokenId);
    // }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        AppStorage.Setting storage setting = AppStorage.layout().setting;
        AppStorage.Word storage w = AppStorage.layout().words[tokenId];

        require(w.info.blockNumber != 0, "ERC721Metadata: URI query for nonexistent token");


        string memory doms;
        for (uint256 i; i < w.domsCount; i++){
            doms = string.concat(
                w.doms[i].dommer.toString(),
                ", ",
                w.doms[i].amount.floatString(18, 3),
                ", ",
                w.doms[i].mention,
                " /n"
            );
        }

        address templateAddress = AppStorage.layout().templates[w.info.template].contAddr;

        return string.concat('data:application/json;base64,', Base64.encode(abi.encodePacked(
              '{"name": "#', tokenId.toString(), 
            '", "description": "', doms,
            '", "external_url": "', bytes(w.info.externalURL).length>0 ? w.info.externalURL : string.concat(setting.defaultExternalURL, tokenId.toString()),
            '", "image": "', image(templateAddress, tokenId),
            '", "attributes": [', attributes(tokenId),
            '], "interaction" : {"read":[],"write":[{"inputs": [{"internalType": "uint256","name": "tokenId","type": "uint256"},{"internalType": "string","name": "mention","type": "string"}],"name": "dom","outputs": [],"stateMutability": "payable","type": "function"},{"inputs": [{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "withdrawWord","outputs": [],"stateMutability": "nonpayable","type": "function"}]}}'
            ))
        );
    }
    
    function attributes(uint256 tokenId) private view returns(string memory tagsOut){
        AppStorage.Word storage w = AppStorage.layout().words[tokenId];
        string memory tagsStr = w.info.tags;

        StringUtils.slice memory s = tagsStr.toSlice();                
        StringUtils.slice memory delim = " ".toSlice(); 
        uint256 sLen = s.count(delim);
        for(uint8 i; i <= sLen; i++){
            tagsOut = string.concat(
                tagsOut, 
                ', {"trait_type": "tag", "value": "',
                s.split(delim).toString(),
                i < sLen ? '"}, ' : '"}'
            );
        }
    }
}