// scripts/deploy.js
// const hre = require("hardhat");
const { ethers } = require('hardhat');

async function main() {
  // We get the contract to deploy
console.log('deploying', 'ok deplyed')
  // const [deployer] = await ethers.getSigners();

  // console.log('Deploying contracts with the account:', deployer.address);
  console.log(2)
  const feeToSetter = '0x70997970C51812dc3A010C7d01b50e0d17dc79C8'
  
  // const Factory = await hre.ethers.getContractFactory("Factory");
  const Factory = await ethers.getContractFactory("Factory");
 const factory = await Factory.deploy(feeToSetter);

//   await factory.deployed();
  console.log("Factory deployed to:", factory.address);

//   const Pair = await hre.ethers.getContractFactory("Pair");
//   // We don't deploy Pair directly as it's used within Factory

//   const WETH = "0x5fbdb2315678afecb367f032d93f642f64180aa3"; // Replace with actual WETH address or deploy a WETH contract

//   const Router = await hre.ethers.getContractFactory("Router");
//   const router = await Router.deploy(factory.address, WETH);

// //   await router.deployed();
//   console.log("Router deployed to:", router.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run scripts/factory.js --network local
