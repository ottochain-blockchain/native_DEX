// scripts/deploy.js
// const hre = require("hardhat");
const { ethers } = require('hardhat');

async function main() {
  // We get the contract to deploy
console.log('deploying', 'ok deplyed')
  console.log(2)
  const feeToSetter = '0x70997970C51812dc3A010C7d01b50e0d17dc79C8'
  
  // const Factory = await hre.ethers.getContractFactory("Factory");
  const Factory = await ethers.getContractFactory("Factory");
 const factory = await Factory.deploy(feeToSetter);

//   await factory.deployed();
  console.log("Factory deployed to:", factory.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run scripts/factory.js --network local
