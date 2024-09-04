// scripts/deploy.js
const hre = require("hardhat");

async function main() {
//   // We get the contract to deploy
//   const Factory = await hre.ethers.getContractFactory("Factory");
//  const factory = await Factory.deploy();

// //   await factory.deployed();
//   console.log("Factory deployed to:", factory.address);

//   const Pair = await hre.ethers.getContractFactory("Pair");
//   // We don't deploy Pair directly as it's used within Factory

  const WETH = "0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9"; // Replace with actual WETH address or deploy a WETH contract
  const factory = "0x8990c5daaa40673ef8826990a6fd8284a0a17d61"
  const Router = await hre.ethers.getContractFactory("Router");
  const router = await Router.deploy(factory, WETH);

//   await router.deployed();
  console.log("Router deployed to:", router.address);
}


const routerAddres = "0xe4f89fb0dbb45378633c05acab071eb998f0a736"


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run scripts/router.js --network local
