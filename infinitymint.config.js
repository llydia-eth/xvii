const config = {
  hardhat: {
    networks: {
      hardhat: {},
      localhost: {
        url: "http://127.0.0.1:8545",
      },
      polygon: {
        url: "https://polygon-rpc.com",
        chainId: 137,
        accounts: {
          mnemonic: "env:ETH_MNEMONIC",
        },
      },
      ganache: {
        chainId: 1337,
        url: "http://127.0.0.1:8545",
        accounts: {
          mnemonic: "session:ganacheMnemonic",
        },
      },
    },
    solidity: {
      version: "0.8.12",
      settings: {
        optimizer: {
          enabled: true,
          runs: 20,
        },
      },
    },
  },
  ganache: {
    chain: {
      chainId: 1337,
    },
    wallet: {
      totalAccounts: 10,
      defaultBalance: "69420",
    },
  },
  settings: {
    networks: {
      ganache: {
        writeMnemonic: true,
      },
    },
  },
  ipfs: {
    web3Storage: {
      token:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweGZjZWYwNjFCYTkxNGZhYTdFNjU3NEI2N0E0NjU4YjIyNzgwMTYxQmQiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NTA0MTM0MTMzMjgsIm5hbWUiOiJpbmZpbml0eS1taW50In0.se1kP3g-ssSs0G8DjIrd2pbUeq1b_OzuCqFoxzepZVA",
      useAlways: true,
    },
  },
  express: {
    port: 1337,
    cors: ["*"],
  },
};
module.exports = config;
