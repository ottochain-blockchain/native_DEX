// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Pair is  ERC20 {
    address public factory;
    address public token0;
    address public token1;

    uint256 private reserve0;
    uint256 private reserve1;
    uint256 public totalLiquiditySupply;

    

    uint256 public INITIALLPTOKENREWORD = 10**3;
    mapping(address => uint256) public liquidityBalanceOf;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);

    constructor( ) ERC20("Ottoswap V1", "OTTO-V1") {
        factory = msg.sender;
    }

    // constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
    //     _mint(msg.sender, initialSupply);
    // }

    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "Pair: FORBIDDEN");
        token0 = _token0;
        token1 = _token1;
    }

    function mint(address to) external returns (uint256 liquidity) {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;
        uint256 lpReword;
        liquidity = (amount0 < amount1) ? amount0 : amount1;
        require(liquidity > 0, "Pair: INSUFFICIENT_LIQUIDITY_MINTED");

        // LP reword
        if (reserve0 == 0 && reserve1 == 0) {
            lpReword = liquidity - INITIALLPTOKENREWORD;  
            // _mint(to, INITIALLPTOKENREWORD);
            // _mint(address(0), INITIALLPTOKENREWORD); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            lpReword = totalSupply() * (liquidity / totalLiquiditySupply );
        }

        _mint(to, lpReword);

        liquidityBalanceOf[to] += liquidity;
        totalLiquiditySupply += liquidity;

        reserve0 = balance0;
        reserve1 = balance1;
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to) external returns (uint256 amount0, uint256 amount1) {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint returnLpTokenReword = balanceOf(address(this));
        // uint256 liquidity = liquidityBalanceOf[msg.sender];

        // uint256 liquidity = (returnLpTokenReword / totalSupply()) * totalLiquiditySupply ;
        require(totalSupply() > 0, "Pair: ZERO_TOTAL_SUPPLY");
        require(totalLiquiditySupply > 0, "Pair: ZERO_TOTAL_LIQUIDITY_SUPPLY");

        uint256 liquidity = (returnLpTokenReword * totalLiquiditySupply) / totalSupply();

        // require(liquidity <= liquidityBalanceOf[msg.sender], "No liquidity for this account");
        require(liquidity <= liquidityBalanceOf[to], string(abi.encodePacked(
            "No liquidity for this account - liquidityBalance: ", 
            Strings.toString(liquidityBalanceOf[msg.sender]), 
            ", liquidityBalanceTo: ", 
            Strings.toString(liquidityBalanceOf[to])
            ))
        );

        amount0 = (liquidity * balance0) / totalSupply();
        amount1 = (liquidity * balance1) / totalSupply();
        // require(amount0 > 0 && amount1 > 0, "Pair: INSUFFICIENT_LIQUIDITY_BURNED");
        require(amount0 > 0 && amount1 > 0, string(abi.encodePacked(
            "Pair: INSUFFICIENT_LIQUIDITY_BURNED - amount0: ", 
            Strings.toString(amount0), 
            ", amount1: ", 
            Strings.toString(amount1),
            ", returnLpTokenReword: ", 
            Strings.toString(returnLpTokenReword),
            ", liquidity: ", 
            Strings.toString(liquidity),
            ", balance0: ", 
            Strings.toString(balance0),
            ", balance1: ", 
            Strings.toString(balance1),
            ", totalLiquiditySupply: ", 
            Strings.toString(totalLiquiditySupply),
            ", totalSupply: ", 
            Strings.toString(totalSupply())
            ))
        );
        

        // _burn(to, balanceOf(to));
        _burn(address(this), returnLpTokenReword);

        liquidityBalanceOf[to] -= liquidity;
        totalLiquiditySupply -= liquidity;

        reserve0 = balance0 - amount0;
        reserve1 = balance1 - amount1;
        IERC20(token0).transfer(to, amount0);
        IERC20(token1).transfer(to, amount1);
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to) external {
        require(amount0Out > 0 || amount1Out > 0, "Pair: INSUFFICIENT_OUTPUT_AMOUNT");
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        require(amount0Out <= balance0 && amount1Out <= balance1, "Pair: INSUFFICIENT_LIQUIDITY");

        if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);

        reserve0 = balance0 - amount0Out;
        reserve1 = balance1 - amount1Out;
        emit Swap(msg.sender, balance0 - reserve0, balance1 - reserve1, amount0Out, amount1Out, to);
    }

    function getReserves() public view returns (uint256 _reserve0, uint256 _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }


    // function mint(address to) external returns (uint256 liquidity) {
    //     // Step 1: Get the current balance of token0 and token1 in this contract
    //     uint256 balance0 = IERC20(token0).balanceOf(address(this));
    //     uint256 balance1 = IERC20(token1).balanceOf(address(this));
        
    //     // Step 2: Calculate the amounts of token0 and token1 that were added
    //     uint256 amount0 = balance0 - reserve0;
    //     uint256 amount1 = balance1 - reserve1;

    //     // Step 3: Determine the amount of liquidity to be minted
    //     liquidity = (amount0 < amount1) ? amount0 : amount1;
    //     require(liquidity > 0, "Pair: INSUFFICIENT_LIQUIDITY_MINTED");

    //     // Step 4: Update the liquidity balance of the provider
    //     balanceOf[to] += liquidity;
    //     totalSupply += liquidity;

    //     // Step 5: Update the reserves
    //     reserve0 = balance0;
    //     reserve1 = balance1;

    //     // Step 6: Emit a Mint event
    //     emit Mint(msg.sender, amount0, amount1);
    // }
}
