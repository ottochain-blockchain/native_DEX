// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  const WETH = "0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9"; // Replace with actual WETH address or deploy a WETH contract
  const factory = "0x3c8841ddf731d168b0b4ffb633995281dae8bc3d"
  const Router = await hre.ethers.getContractFactory("Router");
  const router = await Router.deploy(factory, WETH);

//   await router.deployed();
  console.log("Router deployed to:", router.address);
}

const routerAddres = "0x79c42a0742733f61f110eabab2836397714abba1"

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run scripts/router.js --network local
