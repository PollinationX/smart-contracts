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
      url: 'https://fraa-flashbox-2800-rpc.a.stagenet.tanssi.network',
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
    metisSepoliaTestnet: {
      url: 'https://sepolia.metisdevops.link',
      accounts: [process.env.PRIVATE_KEY]
    },
    mantleTestnet: {
      url: 'https://rpc.testnet.mantle.xyz',
      accounts: [process.env.PRIVATE_KEY]
    },
    mantleTestnetSepolia: {
      url: 'https://rpc.sepolia.mantle.xyz',
      accounts: [process.env.PRIVATE_KEY]
    },
    zetachainTestnet: {
      url: 'https://rpc.ankr.com/zetachain_evm_athens_testnet',
      accounts: [process.env.PRIVATE_KEY]
    },
    fantomTestnet: {
      url: 'https://rpc.testnet.fantom.network',
      accounts: [process.env.PRIVATE_KEY]
    },
    gnosisTestnet: {
      url: 'https://rpc.chiadochain.net',
      accounts: [process.env.PRIVATE_KEY]
    },
    sonicFantomTestnet: {
      url: 'https://rpc.sonic.fantom.network',
      accounts: [process.env.PRIVATE_KEY]
    },
    fantomMainnet: {
      url: 'https://rpc.ankr.com/fantom',
      accounts: [process.env.PRIVATE_KEY]
    },
    oasisSapphireMainnet: {
      url: 'https://sapphire.oasis.io',
      accounts: [process.env.PRIVATE_KEY]
    },
    soneiumMinatoTestnet: {
      url: 'https://rpc.minato.soneium.org',
      accounts: [process.env.PRIVATE_KEY]
    },

  },
  etherscan: {
    // apiKey: process.env.FANTOM_API_KEY,
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
          apiURL: "https://fraa-flashbox-2800-rpc.a.stagenet.tanssi.network",
          browserURL: "https://evmexplorer.tanssi-chains.network/?rpcUrl=https%3A%2F%2Ffraa-flashbox-2800-rpc.a.stagenet.tanssi.network"
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
        network: "metisSepoliaTestnet",
        chainId: 59902,
        urls: {
          apiURL: "https://sepolia-explorer.metisdevops.link/api",
          browserURL: "https://sepolia-explorer.metisdevops.link/api"
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
        network: "mantleTestnetSepolia",
        chainId: 5003,
        urls: {
          apiURL: "https://explorer.sepolia.mantle.xyz/api",
          browserURL: "https://explorer.sepolia.mantle.xyz/api"
        }
      },
      {
        network: "zetachainTestnet",
        chainId: 7001,
        urls: {
          apiURL: "https://explorer.testnet.mantle.xyz/api",
          browserURL: "https://explorer.testnet.mantle.xyz/api"
        }
      },
      {
        network: "fantomTestnet",
        chainId: 4002,
        urls: {
          apiURL: "https://api-testnet.ftmscan.com/api",
          browserURL: "https://testnet.ftmscan.com"
        }
      },
      {
        network: "gnosisTestnet",
        chainId: 10200,
        urls: {
          apiURL: "https://eth-goerli.blockscout.com/api",
          browserURL: "https://eth-goerli.blockscout.com/api"
        }
      },
      {
        network: "sonicFantomTestnet",
        chainId: 64165,
        urls: {
          apiURL: "https://public-sonic.fantom.network/api",
          browserURL: "https://public-sonic.fantom.network/api"
        }
      },
      {
        network: "fantomMainnet",
        chainId: 250,
        urls: {
          apiURL: "https://api.ftmscan.com/api",
          browserURL: "https://ftmscan.com"
        }
      },
      {
        network: "oasisSapphireMainnet",
        chainId: 23294,
        urls: {
          apiURL: "https://nexus.oasis.io",
          browserURL: "https://explorer.sapphire.oasis.io"
        }
      },
      {
        network: "soneiumMinatoTestnet",
        chainId: 1946,
        urls: {
          apiURL: "https://explorer-testnet.soneium.org",
          browserURL: "https://explorer-testnet.soneium.org/api/v2"
        }
      }
    ]
  },
};
