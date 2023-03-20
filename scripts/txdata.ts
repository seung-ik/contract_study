const hre = require("hardhat");
const ethers = require("ethers");

require("dotenv").config();
const { GOERLI_ALCHEMY_KEY } = process.env;

async function main() {
	const provider = new ethers.providers.AlchemyProvider("goerli", GOERLI_ALCHEMY_KEY);
	const tx = await provider.getTransaction("0x85acc6325abd55664d115eecdf8f518032be9dbf911476a77a49db35e2db28fa");
	const txcount = await provider.getTransactionCount("0xB93C3fA33c2A1837cf83DE70c69c7aAB6D7A52e4"); // 해당 주소의 다음 논스값을 조회할수 있다.
	console.log("txcount", txcount);
	console.log(tx);
	console.log(ethers.utils.toUtf8String(tx.data));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
