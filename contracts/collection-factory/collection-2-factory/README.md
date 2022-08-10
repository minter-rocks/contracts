## Collection factory version_2 ERC721 

 - NFT Collection contract version_2
 - the contract is ERC721 enumerable.
 - tokenIds are starting from 0 to (maxSupply - 1).
 - tokenURIs are all in the same format baseURI/tokenId.
 - totalSupply is limited and set once at initializing time.
 - safeMint restricted to the owner.
 - safeMint can be auto increment or you can specify the tokenId.
 - there is a default royalty which can be set once at initializing time and also every token can have its particular royalty and does not use default royalty.
 - owner of the contract can delete default royalty and token royalties and only set royalty for a specific token if they own it.
 - every token owner can log a comment in the contract by its token and address.

### collection attributes:
  - creatorName
  - tokenName
  - tokenSymbol
  - baseURI
  - maxSupply
  - royaltyNumerator
  - royaltyReciever