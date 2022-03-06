const { ethers, upgrades } = require("hardhat");

  async function main() {
    // // Deploying by proxy
    // const IDCard = await ethers.getContractFactory("IDCard");
    // const IDC = await upgrades.deployProxy(IDCard);
    // await IDC.deployed();
    // console.log("IDCard proxy address:", IDC.address);
  
  
    // // Upgrading
    // const IDCard = await ethers.getContractFactory("IDCard");
    // const upgraded = await upgrades.upgradeProxy(IDC.address, IDCard);
    // console.log("upgraded successfully.");


    // simple deploy
    const IDCard = await ethers.getContractFactory("IDCard");
    const IDC = await IDCard.deploy();
    await IDC.deployed();
    console.log("IDCard Contract Address:", IDC.address);
    
  }
    
  main();