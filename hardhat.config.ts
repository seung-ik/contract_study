import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-waffle";
require("dotenv").config();

const PK = process.env.PK as string;
const config: HardhatUserConfig = {
	solidity: "0.8.9",
	networks: {
		goerli: {
			url: `https://eth-goerli.g.alchemy.com/v2/${process.env.GOERLI_ALCHEMY_KEY}`,
			accounts: [PK],
		},
	},
	etherscan: {
		apiKey: process.env.ETHERSCAN_API_KEY,
	},
};

export default config;
