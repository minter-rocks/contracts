const { ethers } = require("hardhat");

  async function main() {
    // simple deploy
    const TagGov = await ethers.getContractFactory("TagGov");
    const DG = await TagGov.deploy();
    await DG.deployed();
    console.log("TagGov Contract Address:", DG.address); 
  }
    
  main();