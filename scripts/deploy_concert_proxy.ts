import { ethers } from "hardhat";

async function main() {
	const Concert = await ethers.getContractFactory("Concert_V1");
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
