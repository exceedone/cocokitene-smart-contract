const hre = require("hardhat");
const { ethers, upgrades } = hre;

const { getContracts, saveContract, sleep } = require("./utils");

async function main() {
    const network = hre.network.name;
    const contracts = await getContracts(network)[network];

    const Meeting = await hre.ethers.getContractFactory("Meeting");
    const meeting = await upgrades.upgradeProxy(
        contracts.meeting,
        Meeting
    );
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
