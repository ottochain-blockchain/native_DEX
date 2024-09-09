// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pair.sol";

contract Factory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

     constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(
        address tokenA, 
        address tokenB
    ) 
        external 
        returns (address pair) 
    {
        require(tokenA != tokenB, "Factory: IDENTICAL_ADDRESSES");
        require(getPair[tokenA][tokenB] == address(0), "Factory: PAIR_EXISTS");
        
        // Create a new pair contract
        bytes memory bytecode = type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tokenA, tokenB));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        
        Pair(pair).initialize(tokenA, tokenB);
        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair; // Reverse mapping
        allPairs.push(pair);
        emit PairCreated(tokenA, tokenB, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Ottoswap: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Ottoswap: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
