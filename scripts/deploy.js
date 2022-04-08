const { ethers, upgrades } = require("hardhat");

  async function main() {
    // simple deploy
    const BTBMarket = await ethers.getContractFactory("BTBMarket");
    const BTBM = await BTBMarket.deploy();
    await BTBM.deployed();
    console.log("BTBMarket Contract Address:", BTBM.address); 
  }
    
  main();