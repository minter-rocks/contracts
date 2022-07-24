const { ethers } = require("hardhat");

  async function main() {
    // simple deploy
    const DonationGov = await ethers.getContractFactory("DonationGov");
    const DG = await DonationGov.deploy();
    await DG.deployed();
    console.log("DonationGov Contract Address:", DG.address); 
  }
    
  main();