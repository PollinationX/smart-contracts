// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const main = async () => {
  try {

    // Library deployment
    const libPXStorage = await hre.ethers.getContractFactory("PXStorage");
    const libInstancePXStorage = await libPXStorage.deploy();
    await libInstancePXStorage.deployed();
    console.log("PXStorage Library Address--->" + libInstancePXStorage.address)

    // Library deployment
    const lib = await hre.ethers.getContractFactory("PXUtils");
    const libInstance = await lib.deploy();
    await libInstance.deployed();
    console.log("PXUtils Library Address--->" + libInstance.address)

    const nftContractFactory = await hre.ethers.getContractFactory(
        "PX",
        { libraries: {
            PXUtils: libInstance.address,
            PXStorage: libInstancePXStorage.address,
        } }
    );
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();

    console.log("Contract deployed to:", nftContract.address);
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
