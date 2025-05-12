// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IHook - Interface for Uniswap V4 Hook contracts
/// @notice Hook contracts allow for custom behavior on swaps, mints, burns, etc.
interface IHook {
    /// @notice Hook that runs before a swap
    function beforeSwap(
        address sender,
        address recipient,
        uint128 amount,
        bytes calldata data
    ) external;

    /// @notice Hook that runs after a swap
    function afterSwap(
        address sender,
        address recipient,
        uint128 amount,
        bytes calldata data
    ) external;

    /// @notice Hook that runs before adding liquidity
    function beforeMint(
        address sender,
        uint128 liquidity,
        bytes calldata data
    ) external;

    /// @notice Hook that runs after adding liquidity
    function afterMint(
        address sender,
        uint128 liquidity,
        bytes calldata data
    ) external;

    /// @notice Hook that runs before removing liquidity
    function beforeBurn(
        address sender,
        uint128 liquidity,
        bytes calldata data
    ) external;

    /// @notice Hook that runs after removing liquidity
    function afterBurn(
        address sender,
        uint128 liquidity,
        bytes calldata data
    ) external;
}
