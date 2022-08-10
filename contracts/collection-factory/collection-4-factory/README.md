## Collection factory version_4 ERC721 

  - NFT Collection contract version_4
  - the contract is ERC721 enumerable.
  - tokenIds are starting from 0 to (maxSupply - 1).
  - tokenURIs can be all similar (baseURI); or all in the same format (baseURI/tokenId).
  - baseURI can be set by the owner of the collection.
  - totalSupply is limited and set once at initializing time.
  - the owner can safeMint single or batch tokens to any address desired.
  - also the owner can add one or more addresses to the white list so they can mint a token.
  - the owner can enable or disable the white list as they want. if disable, every one can mint.
  - there is a default royalty which can be set once at initializing time and also every token can have its particular royalty and does not use default royalty.
  - owner of the contract can delete default royalty and token royalties and only 
  - set royalty for a specific token if they own it.

### collection attributes:
  - creatorName
  - tokenName
  - tokenSymbol
  - baseURI
  - sameURIForAllTokens
  - totalSupply
  - royaltyNumerator
  - royaltyReciever
