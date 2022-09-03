const {ethers} = require("hardhat");
const { GANDHIMONEY_NFT_CONTRACT_ADDRESS } = require("../constants");


async function main() {
  const DEMONftMarketplace = await ethers.getContractFactory(
    "DEMONftMarketplace"
  );
  const demoNftMarketplace = await DemoNftMarketplace.deploy();
  await demoNftMarketplace.deployed();

  console.log("DemoNftMarketplace deployed to: ", demoNftMarketplace.address);

  const GandhiDAO = await ethers.getContractFactory("GandhiDAO");
  const gandhiDAO = await GandhiDAO.deploy(
    demoNftMarketplace.address,
    GANDHIMONEY_NFT_CONTRACT_ADDRESS,
    {
      value: ethers.utils.parseEther("1"),
    }
  );
  await gandhiDAO.deployed();

  console.log("GandhiDAO deployed to: ", gandhiDAO.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
