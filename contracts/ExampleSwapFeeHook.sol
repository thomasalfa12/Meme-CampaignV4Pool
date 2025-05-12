// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./interfaces/IHook.sol";

/// @title ExampleSwapFeeHook
/// @notice Contoh implementasi hook Uniswap V4 untuk testing/mocking event swap, mint, burn
contract ExampleSwapFeeHook is IHook {
    address public immutable manager;

    event HookCalled(string name, address sender, address recipientOrZero, uint128 amount);

    constructor(address _manager) {
        manager = _manager;
    }

    function beforeSwap(
        address sender,
        address recipient,
        uint128 amount,
        bytes calldata
    ) external override {
        emit HookCalled("beforeSwap", sender, recipient, amount);
    }

    function afterSwap(
        address sender,
        address recipient,
        uint128 amount,
        bytes calldata
    ) external override {
        emit HookCalled("afterSwap", sender, recipient, amount);
    }

    function beforeMint(
        address sender,
        uint128 liquidity,
        bytes calldata
    ) external override {
        emit HookCalled("beforeMint", sender, address(0), liquidity);
    }

    function afterMint(
        address sender,
        uint128 liquidity,
        bytes calldata
    ) external override {
        emit HookCalled("afterMint", sender, address(0), liquidity);
    }

    function beforeBurn(
        address sender,
        uint128 liquidity,
        bytes calldata
    ) external override {
        emit HookCalled("beforeBurn", sender, address(0), liquidity);
    }

    function afterBurn(
        address sender,
        uint128 liquidity,
        bytes calldata
    ) external override {
        emit HookCalled("afterBurn", sender, address(0), liquidity);
    }
}
