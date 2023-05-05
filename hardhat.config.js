require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

module.exports = {
  solidity: "0.8.10",
  settings: {
    optimizer: {
      enabled: true,
      runs: 1000
    }
  },
  networks: {
    mumbai: {
      url: process.env.TESTNET_RPC,
      accounts: [process.env.PRIVATE_KEY]
    },
    artheraTestnet: {
      url: 'https://rpc-test.arthera.net',
      chainId: 10243,
      accounts: [process.env.PRIVATE_KEY]
    },
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY
  },
  customChains: [
    {
      network: "artheraTestnet",
      chainId: 10243,
      urls: {
        apiURL: "https://explorer-test.arthera.net/api",
        browserURL: "https://explorer-test.arthera.net"
      }
    }
  ]
};
