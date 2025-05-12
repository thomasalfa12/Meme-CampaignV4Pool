const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");
require("dotenv").config();

const config = require("../deploy/config");

async function main() {
  const [deployer, contributor1, contributor2] = await ethers.getSigners();

  // Get deployed manager contract
  const managerPath = path.resolve(__dirname, "../deploy/deployedAddresses.json");
  const deployed = JSON.parse(fs.readFileSync(managerPath));
  const manager = await ethers.getContractAt("MemeCampaignManager", deployed.manager);

  // === Step 1: Create Campaign ===
  const name = "ShibAii";
  const symbol = "SHIBAII";
  const totalSupply = ethers.utils.parseEther("1000000000"); // 1B
  const targetETH = ethers.utils.parseEther("10");

  const txCreate = await manager.connect(deployer).createCampaign(
    name,
    symbol,
    totalSupply,
    targetETH,
    0 // simple mode, no fee slider, not degen
  );
  const receiptCreate = await txCreate.wait();
  const campaignId = receiptCreate.events[0].args.campaignId.toString();

  console.log(`✅ Campaign ${campaignId} created: ${name} (${symbol})`);

  // === Step 2: Fund the Campaign ===
  const fundAmount1 = ethers.utils.parseEther("4");
  const fundAmount2 = ethers.utils.parseEther("6");

  await manager.connect(contributor1).contributeToCampaign(campaignId, {
    value: fundAmount1,
  });
  console.log(`💰 Contributor 1 funded: ${ethers.utils.formatEther(fundAmount1)} ETH`);

  await manager.connect(contributor2).contributeToCampaign(campaignId, {
    value: fundAmount2,
  });
  console.log(`💰 Contributor 2 funded: ${ethers.utils.formatEther(fundAmount2)} ETH`);

  // === Step 3: Check status and trigger deploy ===
  const campaign = await manager.getCampaign(campaignId);
  if (campaign.funded) {
    console.log("🚀 Target ETH reached! Triggering campaign deployment...");

    // Simulate off-chain relayer call to deployFullCampaign
    console.log("⚙️  Call: deploy/deployFullCampaign.js");
    await require("../deploy/deployFullCampaign.js")();
  } else {
    console.log("⚠️  Campaign has not reached target yet.");
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
