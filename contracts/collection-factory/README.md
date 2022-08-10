
# Collection Factories
 
 - deploy your ERC721/1155 NFT collections in the most gas efficient and simple way possible.
 - your next collection address is visible before you deploy it!
 - access to your all collections in one call in the factory.
 - you only need to specify the collection attributes and create it in one function call. 
 - you can set a default royalty on all tokens of your collection once in deploying time.

## Deployment

 - deploy Factory:
 
   $ npx run scripts/collection-factory/deploy<factory_number>.js (--network <network_name>) 

 - deploy collection:

   $ Factory<factory_number>.newCollection(<collection_attributes>)