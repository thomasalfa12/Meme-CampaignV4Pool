// deploy/deployFullCampaign.js
require("dotenv").config();
const { ethers } = require("hardhat");
const { getDeploymentConfig } = require("./config");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying full campaign with deployer:", deployer.address);

  const config = getDeploymentConfig();
  const MemeCampaignManager = await ethers.getContractFactory("MemeCampaignManager");

  const manager = await MemeCampaignManager.attach(config.managerAddress);
  console.log("Connected to MemeCampaignManager at:", manager.address);

  // Create campaign (simulate):
  const tx = await manager.createCampaign(
    "Shibaii", // name
    "SHIBAI", // symbol
    config.creator, // creator
    config.buybackAddress, // community
    config.feeMode, // simple = 0, advancedNormal = 1, degen = 2
    config.creatorFeeBps,
    config.communityFeeBps
  );
  const receipt = await tx.wait();
  const campaignId = receipt.events.find(e => e.event === 'CampaignCreated').args.id;
  console.log("Campaign created with ID:", campaignId.toString());

  // Simulate funding (send ETH)
  await deployer.sendTransaction({
    to: manager.address,
    value: ethers.utils.parseEther("10"),
    data: ethers.utils.defaultAbiCoder.encode(["uint256"], [campaignId])
  });
  console.log("10 ETH funded to campaign");

  // Finalize (trigger pool creation and token minting)
  const finalizeTx = await manager.finalizeCampaign(campaignId);
  await finalizeTx.wait();
  console.log("Campaign finalized and token launched!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
