(async () => {
  const nftContractFactory = await hre.ethers.getContractFactory(
    "ThreeWordsNFT"
  );
  const nftContract = await nftContractFactory.deploy();

  await nftContract.deployed();

  console.log(`Contract deployed to: ${nftContract.address}`);
})();
