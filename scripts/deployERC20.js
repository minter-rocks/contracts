const { ethers } = require("hardhat");

  async function main() {
    // simple deploy
    const ComunityERC20 = await ethers.getContractFactory("ComunityERC20");
    const C20 = await ComunityERC20.deploy();
    await C20.deployed();
    console.log("ComunityERC20 Contract Address:", C20.address); 
  }
    
  main();