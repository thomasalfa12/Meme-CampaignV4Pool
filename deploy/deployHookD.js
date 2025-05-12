const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("🔧 Deploying Hook contract with dummy manager...");

  const dummyManagerAddress = "0x0000000000000000000000000000000000000000";
  const dummyPoolAddress = "0x0000000000000000000000000000000000000000"; // kalau Hook kamu butuh expectedPool

  const Hook = await ethers.getContractFactory("Hook");
  const hook = await Hook.deploy(dummyManagerAddress, dummyPoolAddress);
  await hook.waitForDeployment(); // 🔧 Ganti dari .deployed()

  const hookAddress = await hook.getAddress();
  console.log("✅ Hook deployed at:", hookAddress);

  // Simpan address ke file
  const outputPath = path.resolve(__dirname, "deployedAddresses.json");
  const addresses = fs.existsSync(outputPath)
    ? JSON.parse(fs.readFileSync(outputPath))
    : {};

  addresses.hook = hookAddress;
  fs.writeFileSync(outputPath, JSON.stringify(addresses, null, 2));

  console.log("📦 Address saved to deployedAddresses.json");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
