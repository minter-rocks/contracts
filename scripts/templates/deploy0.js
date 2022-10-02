const { ethers } = require("hardhat");

  async function main() {
    // simple deploy
    const Template0 = await ethers.getContractFactory("Template0");
    const T0 = await Template0.deploy();
    await T0.deployed();
    console.log("Template0 Contract Address:", T0.address); 
  }
    
  main();