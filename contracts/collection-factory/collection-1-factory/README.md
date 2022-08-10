## Collection factory version_2 ERC721 

 - NFT Collection contract version_1
 - totalSupply is unlimited.
 - token URIs are Basically different.
 - safeMint restricted to the owner.
 - safeMint can be auto increment tokenId or owner of the contract can choose the tokenId.
 - there is a default royalty which can be set once at initializing time and also every token can have its particular royalty and does not use default royalty.
 - owner of the contract can delete default royalty and token royalties and only set royalty for a specific token if they own it.

### collection attributes:
  - creatorName
  - tokenName
  - tokenSymbol
  - royaltyNumerator
  - royaltyReciever