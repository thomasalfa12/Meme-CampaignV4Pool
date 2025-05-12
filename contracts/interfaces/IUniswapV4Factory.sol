// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IUniswapV4Factory - Interface for Uniswap V4 Factory
interface IUniswapV4Factory {
    /// @notice Returns the pool for a given token pair and hook
    function getPool(
        address token0,
        address token1,
        address hook,
        uint24 fee,
        int24 tickSpacing
    ) external view returns (address pool);

    /// @notice Creates a new pool with the given parameters
    function createPool(
        address token0,
        address token1,
        address hook,
        uint24 fee,
        int24 tickSpacing
    ) external returns (address pool);

    /// @notice Owner of the factory (could be DAO or admin)
    function owner() external view returns (address);

    /// @notice Protocol fee controller
    function protocolFeeController() external view returns (address);
}
