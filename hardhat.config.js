require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { YOUR_PRIVATE_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    ottochain: {
      url: "https://rpc.ottochain.io",  // Replace with the actual RPC URL
      chainId: 1234,  // Replace with the actual chain ID for Ottochain
      accounts: [`${YOUR_PRIVATE_KEY}`]  // Replace with your private key
    },
    local: {
      url: "http://127.0.0.1:8545",  // Replace with the actual RPC URL
      // chainId: 1234,  // Replace with the actual chain ID for Ottochain
      accounts: [`${YOUR_PRIVATE_KEY}`]   // Replace with your private key
    }
  }
};
