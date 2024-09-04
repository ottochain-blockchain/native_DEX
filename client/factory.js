// const { ethers } = require("ethers");
// import { ethers} from 'ethers'
const { ethers } = require("ethers");
const PRIVATE_KEY = "0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6"
// Connect to the local Ethereum node
const LOCAL_PROVIDER_URL = "http://127.0.0.1:8545";
// const provider = ethers.providers(LOCAL_PROVIDER_URL);
const provider = new ethers.providers.JsonRpcProvider();
// new ethers.providers.JsonRpcProvider(YOUR_ANKR_PROVIDER_URL);

const wallet = new ethers.Wallet(PRIVATE_KEY);
const signer = wallet.connect(provider);

// const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
const contractAddress = "0x948b3c65b89df0b4894abe91e6d02fe579834f8f";
const abi = [
    {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "token0",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "token1",
            "type": "address"
          },
          {
            "indexed": false,
            "internalType": "address",
            "name": "pair",
            "type": "address"
          },
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "name": "PairCreated",
        "type": "event"
      },
      {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "name": "allPairs",
        "outputs": [
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "tokenA",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "tokenB",
            "type": "address"
          }
        ],
        "name": "createPair",
        "outputs": [
          {
            "internalType": "address",
            "name": "pair",
            "type": "address"
          }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          }
        ],
        "name": "getPair",
        "outputs": [
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];

// Create a contract instance
const contract = new ethers.Contract(contractAddress, abi, provider);

const pairDetail = async () => {
    try {
        console.log(1)
        const tokenA = "0x5fbdb2315678afecb367f032d93f642f64180aa3";
        const tokenB = "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512";
        console.log(2)
    
      
        // const pairAddress = await contract.getPair(tokenA, tokenB);
        // console.log('Pair address:', pairAddress);
        console.log(3)

        // Example: Get the total number of pairs created
        const pairCount = await contract.allPairs(0);
        console.log(4)
        console.log('Total pairs:', pairCount);
        console.log(5)

        
        
    } catch (error) {
        console.log('error', error)
    }
}

pairDetail()