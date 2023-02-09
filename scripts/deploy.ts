import { ethers } from "hardhat";

async function main() {
	const [deployer] = await ethers.getSigners();
	console.log("deployer", deployer.address);

	const Factory = await ethers.getContractFactory("Factory");
	const factory_CA = await Factory.deploy();

	const GrayToken = await ethers.getContractFactory("Token");
	const grayToken_CA = await GrayToken.deploy("GrayToken", "GRAY", 1000);

	console.log("factory CA address: ", factory_CA.address);
	console.log("grayToken CA address: ", grayToken_CA.address);

	const Exchange = await ethers.getContractFactory("Exchange");
	const exchange_CA = await Exchange.deploy(grayToken_CA.address);

	console.log("grayExchange CA address: ", exchange_CA.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
