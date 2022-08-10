
# Collection factory version_5 ERC1155 

## Factory
 
 - deploy your ERC1155 collection in the most gas efficient and simple way possible.
 - your next collection address is visible before you deploy it!
 - access to your all collections in one call in the factory.
 - you only need to specify the collection attributes and create it in one function call. 
 - you can set a default royalty on all tokens of your collection once in deploying time.
 - collection attributes contains:
    - collectionInfo
    - collectionName
    - collectionSymbol
    - royaltyNumerator
    - royaltyReciever

 - deploy Factory 5:

   $ npx run scripts/deploy5.js (--network <network_name>) 

## Collection

- every token id has a cap which owner of the contract sets.
- totalSupply of each id can be maximum of the cap.
- every tokenId has a uri which can be set by the owner.
- newId and safeMint restricted to the owner.
- the owner has to create newId befor they can mint on that Id.
- there is a default royalty which can be set once at initializing time and also every tokenId can have its particular royalty instead of default royalty.
- owner of the contract can delete default royalty and token royalties or set 
- tokenRoyalty only when the token supply is zero.

- deploy collection5:

  $ Factory5.newCollection(<attributes>)