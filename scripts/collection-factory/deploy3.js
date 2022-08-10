const { ethers } = require("hardhat");

  async function main() {
    // simple deploy
    const Collection = await ethers.getContractFactory("Collection3");
    const c = await Collection.deploy();
    await c.deployed();
    console.log("Collection Contract Address:", c.address); 
  }
    
  main();