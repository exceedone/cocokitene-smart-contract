const hre = require("hardhat");
const { ethers, upgrades } = hre;

const { saveContract, sleep } = require("./utils");


async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const network = hre.network.name;

    const Meeting = await hre.ethers.getContractFactory("Meeting");

    const meeting = await upgrades.deployProxy(Meeting, [
        [
            "0x283DC6Ec6DFa11c87947bF6B26e66b6522Bf15Af"
        ]
    ]);
    await meeting.deployed();
    await saveContract(network, "meeting", meeting.address);
    console.log("meetingSC deployed to:", meeting.address);
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(
        meeting.address
    );
    console.log("Implementation contract address:", implementationAddress);
    await sleep(10000);
    await hre.run("verify:verify", {
        address: implementationAddress,
        constructorArguments: []
    });
    console.log("Completed!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
