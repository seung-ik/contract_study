import { expect } from "chai";
import { ethers, waffle } from "hardhat";
import { BigNumber } from "ethers";
import { TTOT_FACTORY_V1 as Factory } from "../typechain-types/contracts/TTOT_Factory_V1.sol";
import { TTOT_Concert_V1 as Concert } from "../typechain-types/contracts/TTOT_Concert_V1";

const toWei = (value: number) => ethers.utils.parseEther(value.toString());

describe("concert", () => {
	let factory: Factory;
	let concert: Concert;
	let owner: any;

	beforeEach(async () => {
		const signers = await ethers.getSigners();
		owner = signers[0];
		const factoryCA = await ethers.getContractFactory("TTOT_FACTORY_V1");
		factory = await factoryCA.deploy();
		await factory.deployed();

		const concertCA = await ethers.getContractFactory("TTOT_Concert_V1");
		concert = await concertCA.deploy(500, factory.address, owner.address, "k연자콘서트", 15900000000, 100);
		await concert.deployed();
	});

	it("should deploy the factory contract", async () => {
		console.log(factory.address);
		console.log(concert.address);
		console.log(owner.address);
	});
});
