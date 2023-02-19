import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const PK = process.env.PK as string;
const config: HardhatUserConfig = {
	solidity: "0.8.9",
	networks: {
		goerli: {
			url: "https://eth-goerli.g.alchemy.com/v2/DclV1nIckLaKzlftg17oaeC2EARw7187",
			accounts: [PK],
		},
	},
};

export default config;
