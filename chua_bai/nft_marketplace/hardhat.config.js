require("@nomiclabs/hardhat-waffle");

const PRIVATE_KEY = ""; // Your wallets private key

module.exports = {
  solidity: {
    version: "0.7.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  networks: {
    rinkeby: {
      url: 'https://rinkeby.infura.io/v3/014b38b8d1bf4292ac1aa2477d0342ba',
      accounts: ['5a6b3ab9b68d490fbaec179ca686167292a6c639e7db5a4bc33a68eba3c5819e']
    },
  },
};
