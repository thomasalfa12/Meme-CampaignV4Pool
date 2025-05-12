// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./UnlockerToken.sol";
import "./interfaces/IUniswapV4Factory.sol";
import "./interfaces/IWeth.sol";
import "./interfaces/IUnlockerToken.sol";
import "./interfaces/IHook.sol";

contract MemeCampaignManager {
    enum Mode {
        Simple,
        AdvancedNormal,
        AdvancedDegen
    }

    struct Campaign {
        string name;
        string symbol;
        address creator;
        uint256 targetAmount;
        uint256 totalRaised;
        bool finalized;
        Mode mode;
        address token;
        address pool;
        mapping(address => uint256) contributions;
        address[] contributors;
    }

    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;

    address public immutable factory;
    address public immutable weth;
    address public immutable hook;
    address public immutable devWallet;
    uint24 public constant FEE = 3000;
    int24 public constant TICK_SPACING = 60;

    event CampaignCreated(uint256 indexed campaignId, address indexed creator);
    event Contributed(uint256 indexed campaignId, address indexed contributor, uint256 amount);
    event Finalized(uint256 indexed campaignId, address token, address pool);

    constructor(
        address _factory,
        address _weth,
        address _devWallet,
        address _hook
    ) {
        factory = _factory;
        weth = _weth;
        devWallet = _devWallet;
        hook = _hook;
    }

    function createCampaign(
        string calldata name,
        string calldata symbol,
        uint256 targetAmount,
        Mode mode
    ) external returns (uint256) {
        uint256 id = campaignCount++;

        Campaign storage c = campaigns[id];
        c.name = name;
        c.symbol = symbol;
        c.creator = msg.sender;
        c.targetAmount = targetAmount;
        c.mode = mode;

        emit CampaignCreated(id, msg.sender);
        return id;
    }

    function contribute(uint256 id) external payable {
        Campaign storage c = campaigns[id];
        require(!c.finalized, "Finalized");
        require(msg.value > 0, "Zero amount");

        if (c.contributions[msg.sender] == 0) {
            c.contributors.push(msg.sender);
        }

        c.contributions[msg.sender] += msg.value;
        c.totalRaised += msg.value;

        emit Contributed(id, msg.sender, msg.value);
    }

    function withdraw(uint256 id) external {
        Campaign storage c = campaigns[id];
        require(!c.finalized, "Finalized");
        uint256 amount = c.contributions[msg.sender];
        require(amount > 0, "No contribution");

        c.contributions[msg.sender] = 0;
        c.totalRaised -= amount;
        payable(msg.sender).transfer(amount);
    }

    function finalizeCampaign(uint256 id) external {
        Campaign storage c = campaigns[id];
        require(!c.finalized, "Already finalized");
        require(c.totalRaised >= c.targetAmount, "Target not met");

        c.finalized = true;

        // Fee logic
        uint256 devFee = (c.totalRaised * 25) / 1000; // 2.5%
        uint256 poolEth = c.totalRaised - devFee;

        // Transfer dev fee
        payable(devWallet).transfer(devFee);

        // Deploy UnlockerToken
        uint256 totalSupply = c.totalRaised;
        UnlockerToken token = new UnlockerToken(c.name, c.symbol, address(this), totalSupply);

        c.token = address(token);

        // Mint tokens to contributors
        for (uint256 i = 0; i < c.contributors.length; i++) {
            address user = c.contributors[i];
            uint256 share = c.contributions[user];

            if (c.mode == Mode.AdvancedDegen) {
                uint256 randomAmount = (uint256(
                    keccak256(abi.encodePacked(block.timestamp, user, id))
                ) % (share * 2));
                token.mint(user, randomAmount);
            } else {
                uint256 amount = share;
                token.mint(user, amount);
            }
        }

        // Wrap ETH
        IWETH(weth).deposit{value: poolEth}();

        // Approve token & WETH to factory
        IUnlockerToken(address(token)).approve(factory, type(uint256).max);
        IWETH(weth).approve(factory, type(uint256).max);


        // Create pool
        address pool = IUniswapV4Factory(factory).createPool(
            address(token),
            weth,
            hook,
            FEE,
            TICK_SPACING
        );
        

        c.pool = pool;

        emit Finalized(id, address(token), pool);
    }

    function handlePostSwap(
        uint256 campaignId,
        address sender,
        address recipient,
        uint128 amount
    ) external {
        Campaign storage c = campaigns[campaignId];
        require(c.finalized, "Not finalized");
        // Add fee logic here if needed
    }

    function getCampaign(uint256 id) external view returns (
        string memory,
        string memory,
        address,
        uint256,
        uint256,
        bool,
        Mode,
        address,
        address
    ) {
        Campaign storage c = campaigns[id];
        return (
            c.name,
            c.symbol,
            c.creator,
            c.targetAmount,
            c.totalRaised,
            c.finalized,
            c.mode,
            c.token,
            c.pool
        );
    }

    function getCampaignSummaries() external view returns (
        string[] memory,
        address[] memory,
        uint256[] memory,
        uint256[] memory,
        bool[] memory
    ) {
        uint256 len = campaignCount;

        string[] memory names = new string[](len);
        address[] memory creators = new address[](len);
        uint256[] memory targets = new uint256[](len);
        uint256[] memory raised = new uint256[](len);
        bool[] memory finalized = new bool[](len);

        for (uint256 i = 0; i < len; i++) {
            Campaign storage c = campaigns[i];
            names[i] = c.name;
            creators[i] = c.creator;
            targets[i] = c.targetAmount;
            raised[i] = c.totalRaised;
            finalized[i] = c.finalized;
        }

        return (names, creators, targets, raised, finalized);
    }

    receive() external payable {}
}
