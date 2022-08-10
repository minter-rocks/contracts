
## Collection factory version_5 ERC1155 

- every token id has a cap which owner of the contract sets.
- totalSupply of each id can be maximum of the cap.
- every tokenId has a uri which can be set by the owner.
- newId and safeMint restricted to the owner.
- the owner has to create newId befor they can mint on that Id.
- there is a default royalty which can be set once at initializing time and also every tokenId can have its particular royalty instead of default royalty.
- owner of the contract can delete default royalty and token royalties or set 
- tokenRoyalty only when the token supply is zero.

- collection attributes:
   - collectionInfo
   - collectionName
   - collectionSymbol
   - royaltyNumerator
   - royaltyReciever