const { ethers, upgrades } = require("hardhat");

  async function main() {
    // // proxy deploy
    // const Collection = await ethers.getContractFactory("Collection");
    // const c = await upgrades.deployProxy(Collection);
    // await c.deployed();
    // console.log("Collection Contract Address:", c.address);
    
    //upgrade
    const Collection = await ethers.getContractFactory("Collection");
    const c = await upgrades.upgradeProxy("0x2E85b497c28DEC383cA9641B1BA78a2ff37B0726", Collection);
    console.log("Collection upgraded");
  }
    
  main();