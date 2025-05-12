// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IMemeCampaignManager - Interface for the MemeCampaignManager contract
interface IMemeCampaignManager {
    /// @notice Called by the Hook after a swap occurs in the associated pool
    /// @param campaignId The ID of the campaign
    /// @param sender The address that initiated the swap
    /// @param recipient The address receiving the output of the swap
    /// @param amount The amount involved in the swap
    function handlePostSwap(
        uint256 campaignId,
        address sender,
        address recipient,
        uint128 amount
    ) external;
}
