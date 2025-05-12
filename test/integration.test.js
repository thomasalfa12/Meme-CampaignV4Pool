// test/integration.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

const FUNDING_AMOUNT = ethers.utils.parseEther("10");
const CONTRIBUTION = ethers.utils.parseEther("0.5");

describe("MemeCampaign Full Integration", function () {
  let manager, hook, factory, weth, unlockerToken;
  let owner, creator, user1, user2;

  beforeEach(async () => {
    [owner, creator, user1, user2] = await ethers.getSigners();

    const WETH = await ethers.getContractFactory("MockWETH");
    weth = await WETH.deploy();

    const Factory = await ethers.getContractFactory("MockUniswapV4Factory");
    factory = await Factory.deploy();

    const UnlockerToken = await ethers.getContractFactory("UnlockerToken");
    unlockerToken = await UnlockerToken.deploy();

    const Manager = await ethers.getContractFactory("MemeCampaignManager");
    manager = await Manager.deploy(
      factory.address,
      weth.address,
      unlockerToken.address,
      owner.address // devWallet
    );

    const Hook = await ethers.getContractFactory("Hook");
    hook = await Hook.deploy(manager.address);
  });

  it("should create a campaign and reach funding", async () => {
    await manager.connect(creator).createCampaign(
      "Shibaii",
      "SHIBAII",
      FUNDING_AMOUNT,
      85, // creator fee
      15, // community fee
      0, // mode simple
      hook.address
    );

    const campaigns = await manager.getCampaignSummaries();
    expect(campaigns.length).to.equal(1);

    await manager.connect(user1).contribute(0, { value: CONTRIBUTION });
    await manager.connect(user2).contribute(0, { value: FUNDING_AMOUNT.sub(CONTRIBUTION) });

    const campaign = await manager.getCampaign(0);
    expect(campaign.totalFunded).to.equal(FUNDING_AMOUNT);

    await manager.connect(creator).launchToken(0);
    const launched = await manager.isLaunched(0);
    expect(launched).to.equal(true);
  });
});