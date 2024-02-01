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
    sepolia: {
      url: process.env.TESTNET_RPC_SEPOLIA,
      accounts: [process.env.PRIVATE_KEY]
    },
    mumbai: {
      url: process.env.TESTNET_RPC,
      accounts: [process.env.PRIVATE_KEY]
    },
    artheraTestnet: {
      url: 'https://rpc-test2.arthera.net',
      chainId: 10243,
      accounts: [process.env.PRIVATE_KEY]
    },
    beresheetEVM: {
      url: 'https://beresheet-evm.jelliedowl.net',
      chainId: 2022,
      accounts: [process.env.PRIVATE_KEY]
    },
    EdgeEVM: {
      url: 'https://edgeware-evm.jelliedowl.net',
      chainId: 2021,
      accounts: [process.env.PRIVATE_KEY]
    },
    immu3Testnet: {
      url: 'https://fraa-dancebox-3043-rpc.a.dancebox.tanssi.network',
      accounts: [process.env.PRIVATE_KEY]
    },
    oasisSapphireTestnet: {
      url: 'https://testnet.sapphire.oasis.dev',
      accounts: [process.env.PRIVATE_KEY]
    },
    metisGoerliTestnet: {
      url: 'https://goerli.gateway.metisdevops.link',
      accounts: [process.env.PRIVATE_KEY]
    },
    mantleTestnet: {
      url: 'https://rpc.testnet.mantle.xyz',
      accounts: [process.env.PRIVATE_KEY]
    },
    zetachainTestnet: {
      url: 'https://rpc.ankr.com/zetachain_evm_athens_testnet',
      accounts: [process.env.PRIVATE_KEY]
    },

  },
  etherscan: {
    apiKey: process.env.SEPOLIASCAN_API_KEY,
    // apiKey: process.env.POLYGONSCAN_API_KEY,
    // apiKey: process.env.EDGSCAN_API_KEY,
    customChains: [
      {
        network: "artheraTestnet",
        chainId: 10243,
        urls: {
          apiURL: "https://explorer-test2.arthera.net/api",
          browserURL: "https://explorer-test2.arthera.net"
        }
      },
      {
        network: "beresheetEVM",
        chainId: 2022,
        urls: {
          apiURL: "https://testnet.edgscan.live/api",
          browserURL: "https://testnet.edgscan.live"
        }
      },
      {
        network: "EdgeEVM",
        chainId: 2021,
        urls: {
          apiURL: "https://edgscan.live/api",
          browserURL: "https://edgscan.live"
        }
      },
      {
        network: "immu3Testnet",
        chainId: 3100,
        urls: {
          apiURL: "https://fraa-dancebox-3043-rpc.a.dancebox.tanssi.network",
          browserURL: "https://polkadot.js.org/apps/?rpc=wss://fraa-dancebox-3043-rpc.a.dancebox.tanssi.network#/explorer"
        }
      },
      {
        network: "oasisSapphireTestnet",
        chainId: 23295,
        urls: {
          apiURL: "https://testnet.explorer.sapphire.oasis.dev",
          browserURL: "https://testnet.explorer.sapphire.oasis.dev"
        }
      },
      {
        network: "metisGoerliTestnet",
        chainId: 599,
        urls: {
          apiURL: "https://goerli.explorer.metisdevops.link/api",
          browserURL: "https://goerli.explorer.metisdevops.link/api"
        }
      },
      {
        network: "mantleTestnet",
        chainId: 5001,
        urls: {
          apiURL: "https://explorer.testnet.mantle.xyz/api",
          browserURL: "https://explorer.testnet.mantle.xyz/api"
        }
      },
      {
        network: "zetachainTestnet",
        chainId: 7001,
        urls: {
          apiURL: "https://explorer.testnet.mantle.xyz/api",
          browserURL: "https://explorer.testnet.mantle.xyz/api"
        }
      }
    ]
  },

};
