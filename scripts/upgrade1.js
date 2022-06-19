/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction
} = require('./libraries/diamond.js')
    
const { assert } = require('chai')

async function deployERC721SolidState () { 

  const diamondAddress = "0xB42cE907d99b74578b9913A560B9c5C1A237356b" //diamond on polygon
  let  diamondCut = await ethers.getContractAt('DiamondCutFacet', diamondAddress)

  let tx


  // deploy facet
  console.log('')
  console.log('Deploying ERC721SolidState')
  const FacetName = "ERC721SolidState"
  const cut = []
  const Facet = await ethers.getContractFactory(FacetName)
  const facet = await Facet.deploy()
  await facet.deployed()
  console.log(`${FacetName} deployed: ${facet.address}`)
  cut.push({
    facetAddress: facet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(facet).remove(['init()'])
  })

  // upgrade diamond with facet
  console.log('')
  console.log('Diamond Cut:', cut)
  let functionCall = facet.interface.encodeFunctionData('init')
  tx = await diamondCut.diamondCut(cut, facet.address, functionCall)
  console.log('Diamond cut tx: ', tx.hash)
  console.log('Completed diamond cut')
  return facet.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployERC721SolidState()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployERC721SolidState = deployERC721SolidState
