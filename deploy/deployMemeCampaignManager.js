const { ethers } = require("hardhat");
const config = require("./config");
require("dotenv").config();
const fs = require("fs");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  const MemeCampaignManager = await ethers.getContractFactory("MemeCampaignManager");

  const manager = await MemeCampaignManager.deploy(
    config.UNISWAP_V4_FACTORY,
    config.WETH,
    config.DEV_WALLET,
    config.HOOK
  );

  await manager.waitForDeployment(); // <-- Gantikan ini!

  console.log("✅ MemeCampaignManager deployed at:", await manager.getAddress());

  fs.writeFileSync(
    "./deploy/manager-address.json",
    JSON.stringify({ address: await manager.getAddress() }, null, 2)
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
