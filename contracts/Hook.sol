// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./interfaces/IHook.sol";
import "./interfaces/IMemeCampaignManager.sol";

contract Hook is IHook {
    address public immutable memeCampaignManager;
    address public immutable expectedPool; // misal Anda tahu pool-nya saat deploy

    constructor(address _memeCampaignManager, address _expectedPool) {
        memeCampaignManager = _memeCampaignManager;
        expectedPool = _expectedPool;
    }

    modifier onlyPool() {
        require(msg.sender == expectedPool, "Only pool can call");
        _;
    }

    function beforeSwap(
        address,
        address,
        uint128,
        bytes calldata
    ) external override {}

    function afterSwap(
        address sender,
        address recipient,
        uint128 amount,
        bytes calldata data
    ) external override onlyPool {
        (uint256 campaignId) = abi.decode(data, (uint256));

        IMemeCampaignManager(memeCampaignManager).handlePostSwap(
            campaignId,
            sender,
            recipient,
            amount
        );
    }

    // Empty optional hooks
    function beforeMint(address, uint128, bytes calldata) external override {}
    function afterMint(address, uint128, bytes calldata) external override {}
    function beforeBurn(address, uint128, bytes calldata) external override {}
    function afterBurn(address, uint128, bytes calldata) external override {}
}
