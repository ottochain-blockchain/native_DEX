// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  // We get the contract to deploy
  const Factory = await hre.ethers.getContractFactory("Factory");
 const factory = await Factory.deploy();

//   await factory.deployed();
  console.log("Factory deployed to:", factory.address);

  const Pair = await hre.ethers.getContractFactory("Pair");
  // We don't deploy Pair directly as it's used within Factory

  const WETH = "0x5fbdb2315678afecb367f032d93f642f64180aa3"; // Replace with actual WETH address or deploy a WETH contract

  const Router = await hre.ethers.getContractFactory("Router");
  const router = await Router.deploy(factory.address, WETH);

//   await router.deployed();
  console.log("Router deployed to:", router.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
