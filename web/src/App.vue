<script setup>
import { onMounted, ref } from "vue";
import { BigNumber, ethers } from "ethers";
import twitterLogo from "./assets/twitter-logo.svg";
import ThreeWordsNFT from "../../artifacts/contracts/ThreeWordsNFT.sol/ThreeWordsNFT.json";

const currentAccount = ref(null);
const mintedNFTsSoFar = ref(null);
const isMinting = ref(false);
const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDRESS;
const TWITTER_HANDLE = "lightyaer";
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;

onMounted(() => {
  checkIfWalletIsConnected();
  getMintedNFTsSoFar();
});

const checkIfWalletIsConnected = async () => {
  const { ethereum } = window;
  if (!ethereum) {
    console.log("Make sure meta mask is connected");
    return;
  }

  let chainId = await ethereum.request({
    method: "eth_chainId",
  });
  console.log(`Connected to Chain ${chainId}`);
  const goerliChainId = "0x5";
  if (chainId !== goerliChainId) {
    alert(
      "You are not connected to the Goerli Test Network, please switch to goerli network & reload"
    );
    return;
  }

  const accounts = await ethereum.request({
    method: "eth_accounts",
  });

  if (accounts.length !== 0) {
    const account = accounts[0];
    console.log("Found an authorized account:", account);
    currentAccount.value = account;
    await setupEventListener();
  } else {
    console.log("No authorized account found");
  }
};

const connectWallet = async () => {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      alert("Get Metamask");
      return;
    }

    const [firstAccount] = await ethereum.request({
      method: "eth_requestAccounts",
    });
    console.log("Connected", firstAccount);
    currentAccount.value = firstAccount;
    await setupEventListener();
  } catch (error) {
    console.log(error);
  }
};

const connectContract = (ethereum) => {
  try {
    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    return new ethers.Contract(CONTRACT_ADDRESS, ThreeWordsNFT.abi, signer);
  } catch (error) {
    console.log(error);
  }
};

const getMintedNFTsSoFar = async () => {
  try {
    const { ethereum } = window;

    const connectedContract = connectContract(ethereum);
    let [current, total] = await connectedContract.getTotalNFTsMintedSoFar();
    mintedNFTsSoFar.value = `${BigNumber.from(
      current
    ).toString()}/${BigNumber.from(total).toString()} NFTs minted so far`;
  } catch (error) {
    console.log(error);
  }
};

const setupEventListener = async () => {
  try {
    const { ethereum } = window;

    if (ethereum) {
      const connectedContract = connectContract(ethereum);

      connectedContract.on("NewThreeWordsNFTMinted", (from, tokenId) => {
        console.log(from, tokenId.toNumber());
        alert(
          `Hey there! We've minted your NFT and sent it to your wallet. It may be blank right now. It can take a max of 10 min to show up on OpenSea. Here's the link: https://testnets.opensea.io/assets/${CONTRACT_ADDRESS}/${tokenId.toNumber()}`
        );
      });

      console.log("Setup event listener!");
    } else {
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    console.log(error);
  }
};

const askContractToMintNFT = async () => {
  try {
    const { ethereum } = window;
    if (ethereum) {
      const connectedContract = connectContract(ethereum);

      console.log("Going to pop Wallet now to pay gas..");
      isMinting.value = true;
      let nftTxn = await connectedContract.mintNFT();
      console.log("Mining... please wait");
      await nftTxn.wait();

      console.log(
        `MINED, see transaction: https://goerli.etherscan.io/tx/${nftTxn.hash}`
      );
      await getMintedNFTsSoFar();
      isMinting.value = false;
    } else {
      console.log("Ethereum object doesn't exist");
      isMinting.value = false;
    }
  } catch (error) {
    console.log(error);
    isMinting.value = false;
  }
};
</script>

<template>
  <div class="App">
    <div class="container">
      <div class="header-container">
        <p class="header gradient-text">Three Words NFT Collection</p>
        <p class="sub-text">
          Each unique.
          <br />
          Each beautiful.
          <br />
          Discover your NFT today with
        </p>
        <p class="sub-text gradient-text">Just Three Words</p>
        <p class="sub-text mint-count">{{ mintedNFTsSoFar }}</p>
        <button
          v-if="currentAccount && !isMinting"
          @click="askContractToMintNFT"
          class="cta-button mint-button"
        >
          Mint NFT
        </button>
        <button v-else-if="isMinting" class="cta-button mint-button">
          Please WAIT..
        </button>
        <button
          v-else
          @click="connectWallet"
          class="cta-button connect-wallet-button"
        >
          Connect to Wallet
        </button>
      </div>
      <div class="footer-container">
        <img alt="Twitter Logo" class="twitter-logo" :src="twitterLogo" />
        <div>
          <p class="footer-text">
            Made with ❤️ by
            <a
              class="footer-text"
              :href="TWITTER_LINK"
              target="_blank"
              rel="noreferrer"
            >
              @{{ TWITTER_HANDLE }}
            </a>
          </p>
        </div>
        <a
          class="footer-text"
          href="https://twitter.com/_buildspace"
          target="_blank"
          rel="noreferrer"
        >
          Built on @_buildspace
        </a>
      </div>
    </div>
  </div>
</template>

<style>
body,
html {
  margin: 0;
}

body {
  padding: 0;
  font-family: -apple-system, Inter, BlinkMacSystemFont, "Segoe UI", "Roboto",
    "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue",
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, "Courier New",
    monospace;
}

.App {
  height: 100vh;
  background-color: #0d1116;
  overflow: scroll;
  text-align: center;
}

.container {
  height: 100%;
  background-color: #0d1116;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.header-container {
  padding-top: 3rem;
}

.header {
  margin: 0;
  font-size: 3rem;
  font-weight: bold;
}

.sub-text {
  font-size: 2rem;
  color: white;
  line-height: 4rem;
}

.gradient-text {
  background: -webkit-linear-gradient(left, #b016ff 30%, #ffe900 60%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.cta-button {
  height: 3rem;
  border: 0;
  width: auto;
  padding: 0 3rem;
  border-radius: 0.5rem;
  cursor: pointer;
  font-size: 1rem;
  font-weight: bold;
  color: white;
}

.connect-wallet-button {
  background: -webkit-linear-gradient(left, #ff4774, #35aee2);
  background-size: 200% 200%;
  animation: gradient-animation 4s ease infinite;
}

.mint-button {
  background: -webkit-linear-gradient(left, #b016ff, #ffe900);
  background-size: 200% 200%;
  animation: gradient-animation 4s ease infinite;
}

.opensea-button {
  background-color: rgb(32, 129, 226);
}

.mint-count {
  color: white;
  font-size: 1rem;
  font-weight: bold;
}

.footer-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding-bottom: 30px;
}

.twitter-logo {
  width: 35px;
  height: 35px;
}

.footer-text {
  color: white;
  font-size: 16px;
  font-weight: bold;
}

/* KeyFrames */
@-webkit-keyframes gradient-animation {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}
@-moz-keyframes gradient-animation {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}
@keyframes gradient-animation {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}
</style>
