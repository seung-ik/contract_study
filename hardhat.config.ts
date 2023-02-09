import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const PK = process.env.PK as string;
const config: HardhatUserConfig = {
	solidity: "0.8.9",
	networks: {
		hardhat: {
			gas: 10000000,
			gasPrice: 875000000,
		},
		goerli: {
			url: "https://ethereum-goerli-rpc.allthatnode.com/Ts31EORi6lEQKsUSFxWejFJAeuXq62hV",
			accounts: [PK],
		},
	},
};

export default config;
