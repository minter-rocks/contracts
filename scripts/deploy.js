const { ethers, upgrades } = require("hardhat");

  async function main() {
    // simple deploy
    const NFTFactory = await ethers.getContractFactory("NFTFactory");
    const Factory = await NFTFactory.deploy();
    await Factory.deployed();
    console.log("NFTFactory Contract Address:", Factory.address); 
  }
    
  main();