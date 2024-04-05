import "@nomiclabs/hardhat-waffle";
import { HardhatUserConfig } from 'hardhat/types';

import "@tenderly/hardhat-tenderly";
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-ethers';
import 'hardhat-typechain';
import 'hardhat-gas-reporter';
import "hardhat-abi-exporter"
import "hardhat-deploy";
import "hardhat-log-remover";
import "@openzeppelin/hardhat-upgrades";

const dotenv = require('dotenv');
dotenv.config();

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const INFURA_API_KEY = process.env.INFURA_API_KEY;
const DEPLOYER_PRIVATE_KEY = process.env.DEPLOYER_PRIVATE_KEY;

const config: HardhatUserConfig & { namedAccounts: any } = {
    abiExporter: {
        path: "./abi",
        clear: true,
        flat: true
    },
    solidity: {
        compilers: [
            {
                version: "0.8.13",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    }
                }
            },
        ]
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY
    },
    gasReporter: {
        currency: "USD",
        enabled: (process.env.REPORT_GAS) ? true : false,
        coinmarketcap: process.env.COINMARKETCAP_API_KEY,
        excludeContracts: ["contracts/mocks/", "contracts/libraries/"],
    },
    mocha: {
        timeout: 600000
    },
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            // forking: {
            //   url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_KEY}` || "",
            //   blockNumber: 12618875
            // }
        },
        mainnet: {
            accounts: [DEPLOYER_PRIVATE_KEY as string],
            url: 'https://mainnet.infura.io/v3/' + INFURA_API_KEY,
            chainId: 1
        },
        goerli: {
            accounts: [DEPLOYER_PRIVATE_KEY as string],
            url: 'https://goerli.infura.io/v3/' + INFURA_API_KEY,
            chainId: 5
        },
        sepolia: {
            accounts: [DEPLOYER_PRIVATE_KEY as string],
            url: 'https://sepolia.infura.io/v3/' + INFURA_API_KEY,
            chainId: 11155111
        }
    },
    typechain: {
        outDir: "./types",
        target: "ethers-v5",
    },
    namedAccounts: {
        deployer: {
            default: 0
        }
    },
    paths: {
        artifacts: "artifacts",
        cache: "cache",
        deploy: "deploy",
        deployments: "deployments",
        imports: "imports",
        sources: "contracts",
        tests: "test",
    },
}

export default config;
