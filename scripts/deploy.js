const { ethers, upgrades } = require("hardhat");

  async function main() {
    // simple deploy
    const Collection = await ethers.getContractFactory("Collection");
    const c = await upgrades.deployProxy(Collection);
    await c.deployed();
    console.log("Collection Contract Address:", c.address); 
  }
    
  main();