const hre = require("hardhat");
const ethers = require("ethers");

require("dotenv").config();
const { GOERLI_ALCHEMY_KEY } = process.env;

async function main() {
	const provider = new ethers.providers.AlchemyProvider("goerli", GOERLI_ALCHEMY_KEY);
	const tx = await provider.getTransaction("0x1a73f3c12c83fe772fbf8484d15da456d3d52b3276527e793c8f2781752bb4bd");
	// 해당 주소의 다음 논스값을 조회할수 있다.
	// eoa
	const eoaTxCount = await provider.getTransactionCount("0xB93C3fA33c2A1837cf83DE70c69c7aAB6D7A52e4");
	const caTxCount = await provider.getTransactionCount("0xc8aeDd5972304e4a0487FD7Bf03173548b5f2D0D");
	console.log("eoa tx count", eoaTxCount);
	console.log("ca tx count", caTxCount);
	// console.log(tx);
	// console.log(ethers.utils.toUtf8String(tx.data));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
