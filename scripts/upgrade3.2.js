/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction
} = require('./libraries/diamond.js')
    
const { assert } = require('chai')

async function deployOnchainMetadata2 () { 

  const diamondAddress = "0xB42cE907d99b74578b9913A560B9c5C1A237356b" //diamond on polygon
  let  diamondCut = await ethers.getContractAt('DiamondCutFacet', diamondAddress)

  let tx


  // deploy facet
  console.log('')
  console.log('Deploying OnchainMetadata2')
  const FacetName = "OnchainMetadata2"
  const cut = []
  const Facet = await ethers.getContractFactory(FacetName)
  const facet = await Facet.deploy()
  await facet.deployed()
  console.log(`${FacetName} deployed: ${facet.address}`)
  cut.push({
    facetAddress: facet.address,
    action: FacetCutAction.Replace,
    functionSelectors: getSelectors(facet)
  })

  // upgrade diamond with facet
  console.log('')
  console.log('Diamond Cut:', cut)
  tx = await diamondCut.diamondCut(cut, ethers.constants.AddressZero, '0x')
  console.log('Diamond cut tx: ', tx.hash)
  console.log('Completed diamond cut')
  return facet.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployOnchainMetadata2()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployOnchainMetadata2 = deployOnchainMetadata2
