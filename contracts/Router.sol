// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Factory.sol";
import "./Pair.sol";
import './interfaces/IWETH.sol';

contract Router {
    address public factory;
    address public WETH;

     modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'ottoswapV1Router: EXPIRED');
        _;
    }

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

     receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) 
        external 
        returns (uint256 amountA, uint256 amountB, uint256 liquidity) 
    {
        if (Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            Factory(factory).createPair(tokenA, tokenB);
        }
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = Factory(factory).getPair(tokenA, tokenB);
        IERC20(tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(tokenB).transferFrom(msg.sender, pair, amountB);
        liquidity = Pair(pair).mint(to);
    }

     function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) 
        external 
        payable 
        ensure(deadline) 
        returns (uint amountToken, uint amountETH, uint liquidity) 
    {
         if (Factory(factory).getPair(token, WETH) == address(0)) {
            Factory(factory).createPair(token, WETH);
        }
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        // address pair = UniswapV2Library.pairFor(factory, token, WETH);
        address pair = Factory(factory).getPair(token, WETH);
        // TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IERC20(token).transferFrom(msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        // liquidity = IUniswapV2Pair(pair).mint(to);
        liquidity = Pair(pair).mint(to);
        // if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH); // refund dust eth, if any
        if (msg.value > amountETH) IWETH(WETH).transfer(msg.sender, msg.value - amountETH); // refund dust eth, if any
    }

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) 
        internal 
        returns (uint256 amountA, uint256 amountB) 
    {
        (uint256 reserveA, uint256 reserveB) = Pair(Factory(factory).getPair(tokenA, tokenB)).getReserves();
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = (amountADesired * reserveB) / reserveA;
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "Router: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = (amountBDesired * reserveA) / reserveB;
                require(amountAOptimal >= amountAMin, "Router: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) 
        public 
        returns (uint256 amountA, uint256 amountB) 
    {
        address pair = Factory(factory).getPair(tokenA, tokenB);
        // Pair(pair).transferFrom(msg.sender, pair, liquidity);
        IERC20(pair).transferFrom(msg.sender, pair, liquidity);
        (uint256 amount0, uint256 amount1) = Pair(pair).burn(to, address(0), false);
        (address token0,) = sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "Router: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "Router: INSUFFICIENT_B_AMOUNT");
    }

    function _removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        address router,
        bool isEth
    ) 
        private 
        returns (uint256 amountA, uint256 amountB) 
    {
        address pair = Factory(factory).getPair(tokenA, tokenB);
        // Pair(pair).transferFrom(msg.sender, pair, liquidity);
        IERC20(pair).transferFrom(msg.sender, pair, liquidity);
        (uint256 amount0, uint256 amount1) = Pair(pair).burn(to, router, isEth);
        (address token0,) = sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "Router: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "Router: INSUFFICIENT_B_AMOUNT");
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address payable to,
        uint deadline
    ) 
        external 
        ensure(deadline) 
        returns (uint amountToken, uint amountETH) 
    {
        (amountToken, amountETH) = _removeLiquidity( 
            token, 
            WETH, 
            liquidity, 
            amountTokenMin, 
            amountETHMin,
            to, 
            address(this),
            true
        );
        // TransferHelper.safeTransfer(token, to, amountToken);

        uint256 routerTkonBlance = IERC20(token).balanceOf(address(this));
        // IERC20(token).transfer(to, amountToken);
        IERC20(token).transfer(to, routerTkonBlance);

        uint256 routerWethBalance = IWETH(WETH).balanceOf(address(this));
        require(routerWethBalance > 0, "Router: Insufficient WETH balance");
        IWETH(WETH).withdraw(routerWethBalance);
        // // TransferHelper.safeTransferETH(to, amountETH);
        to.transfer(routerWethBalance);
    }


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to
    ) 
        external 
        returns (uint256[] memory amounts) 
    {
        amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "Router: INSUFFICIENT_OUTPUT_AMOUNT");
        // IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).transferFrom(msg.sender, Factory(factory).getPair(path[0], path[1]), amountIn);
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    )
        external
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'OttoswapV1Router: INVALID_PATH');
        // amounts = UniswapV2Library.getAmountsOut(factory, msg.value, path);
        amounts = getAmountsOut(msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'OttoswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        // assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        assert(IWETH(WETH).transfer(Factory(factory).getPair(path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address payable to, 
        uint deadline
    )
        external
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'OttoSwapV1Router: INVALID_PATH');
        // amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        amounts = getAmountsOut(amountIn, path);
        // require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        require(amounts[amounts.length - 1] >= amountOutMin, "Router: INSUFFICIENT_OUTPUT_AMOUNT");
        // TransferHelper.safeTransferFrom(path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]);


        IERC20(path[0]).transferFrom(msg.sender, Factory(factory).getPair(path[0], path[1]), amountIn);
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        // TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
        to.transfer(amounts[amounts.length - 1]);
    }
    

    function _swap(
        uint256[] memory amounts, 
        address[] memory path, 
        address _to
    ) 
        internal 
    {
        for (uint256 i; i < path.length - 1; i++) {
            address input = path[i];
            address output = path[i + 1];
            (address token0, ) = sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
            address to = i < path.length - 2 ? Factory(factory).getPair(output, path[i + 2]) : _to;
            Pair(Factory(factory).getPair(input, output)).swap(amount0Out, amount1Out, to);
        }
    }

    function getAmountsOut(
        uint256 amountIn, 
        address[] memory path
    ) 
        public 
        view 
        returns (uint256[] memory amounts) 
    {
        require(path.length >= 2, "Router: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = Pair(Factory(factory).getPair(path[i], path[i + 1])).getReserves();
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountOut(
        uint256 amountIn, 
        uint256 reserveIn, 
        uint256 reserveOut
    ) 
        public
        pure 
        returns (uint256 amountOut) 
    {
        require(amountIn > 0, "Router: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "Router: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function sortTokens(
        address tokenA, 
        address tokenB
    ) 
        public 
        pure 
        returns (address token0, address token1) 
    {
        require(tokenA != tokenB, "Router: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
}
