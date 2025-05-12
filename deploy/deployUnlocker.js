const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying UnlockerToken with account:", deployer.address);

  const UnlockerToken = await ethers.getContractFactory("UnlockerToken");

  const name = "Unlocker Token";
  const symbol = "UNL";
  const owner = deployer.address;
  const totalSupply = ethers.parseEther("1000000"); // 1 juta token

  const token = await UnlockerToken.deploy(name, symbol, owner, totalSupply);
  await token.waitForDeployment();

  const tokenAddress = await token.getAddress();
  console.log("UnlockerToken deployed at:", tokenAddress);

  fs.writeFileSync(
    path.join(__dirname, "deploy-addresses.json"),
    JSON.stringify({ unlockerToken: tokenAddress }, null, 2)
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
