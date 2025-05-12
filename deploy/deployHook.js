// deploy/deployHook.js
const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("🔧 Deploying Hook contract with account:", deployer.address);

  const managerAddress = "0xe49da1C2AcD8AC23306C6eAE4f3CB018Ca3cd506"; // ganti dengan address kamu yang valid

  const Hook = await ethers.getContractFactory("ExampleSwapFeeHook");
  const hook = await Hook.deploy(managerAddress); // ← HANYA argumen yang dibutuhkan

  await hook.waitForDeployment();
  console.log("✅ Hook deployed at:", await hook.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
