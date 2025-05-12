const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MemeCampaignManager", function () {
  let manager, hook, deployer;

  beforeEach(async function () {
    [deployer] = await ethers.getSigners();

    const Hook = await ethers.getContractFactory("Hook");
    hook = await Hook.deploy(ethers.constants.AddressZero);
    await hook.deployed();

    const Manager = await ethers.getContractFactory("MemeCampaignManager");
    manager = await Manager.deploy(hook.address, deployer.address);
    await manager.deployed();
  });

  it("should deploy and create a simple campaign", async () => {
    const tx = await manager.createCampaign(
      "SHIB AII",
      "ShibAII",
      "SHBA",
      "https://image.url",
      ethers.utils.parseEther("10"),
      true, // hardCapMode
      false, // publicFinalize
      0, // Mode.Simple
      85 // creatorFee
    );
    const receipt = await tx.wait();
    expect(receipt.events[0].event).to.equal("CampaignCreated");
  });
});
