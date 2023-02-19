require("dotenv").config();
const ethers = require("ethers");

const FACTORY_ABI = require("./factoryABI.json");
const FACTORY_ADDR = "0x1F98431c8aD98523631AE4a59f267346ea31F984";

const { ALCHEMY_KEY } = process.env;
const provider = new ethers.providers.WebSocketProvider("wss://eth-mainnet.g.alchemy.com/v2/lrw_iU94U2NGOl2vkbsoB0W0Fd4iJdr3");
const contract = new ethers.Contract(FACTORY_ADDR, FACTORY_ABI, provider);

async function main() {
	const filter = contract.filters.PoolCreated(null, "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", 3000, null, null);
	// const filter = contract.filters.PoolCreated(null, null, null, null, null);
	const results = await contract.queryFilter(filter, 16605482, "latest").then((res) =>
		res.map((el) => {
			return {
				blockNumber: el.blockNumber,
				args: el.args,
			};
		})
	);
	console.log(results, "결과");
}
main();
