import { expect } from "chai";
import { ethers, waffle } from "hardhat";
import { BigNumber } from "ethers";
import { TTOT_FACTORY_V1 as Factory } from "../typechain-types/contracts/TTOT_Factory_V1.sol";

const toWei = (value: number) => ethers.utils.parseEther(value.toString());

describe("concert", () => {
	let factory: Factory;

	beforeEach(async () => {
		const factoryCA = await ethers.getContractFactory("TTOT_FACTORY_V1");
		factory = await factoryCA.deploy();
		await factory.deployed();
	});

	it("should deploy the factory contract", async () => {
		console.log(factory);
	});
});
