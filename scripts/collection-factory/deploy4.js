const { ethers } = require("hardhat");

  async function main() {
    // simple deploy
    const Factory = await ethers.getContractFactory("Factory4");
    const F = await Factory.deploy();
    await F.deployed();
    console.log("Factory Contract Address:", F.address); 
  }
    
  main();