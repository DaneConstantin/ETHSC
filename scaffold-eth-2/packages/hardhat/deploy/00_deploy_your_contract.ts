import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

import { Contract } from "ethers";
const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, log } = hre.deployments;
  let ethers = require('../node_modules/ethers')
  log("Deploying CARNFT contract...");
  const carNFTDeployment = await deploy("SolidLuxuryNFT", {
    from: deployer,
    args: ["SolidLuxuryNFT","SLNFT",deployer],
    log: true,
    autoMine: true,
  });

  log("Deploying LuxCoin contract...");
  const carTokenDeployment = await deploy("LuxCoin", {
    from: deployer,
    args: [],
    log: true,
    autoMine: true,
  });

  log("Deploying CarLeasing contract...");
  const carLeasingDeployment = await deploy("CarLeasing", {
    from: deployer,
    args: [carNFTDeployment.address, carTokenDeployment.address, ethers.parseEther("1"), deployer], // rentalRatePerSecond set to 1 (adjust as necessary), initially rentwallet set to owner
    log: true,
    autoMine: true,
  });

  // Get the deployed contracts to interact with them after deploying
  // Get the deployed contracts to interact with them after deploying
  const SolidLuxuryNFT = await hre.ethers.getContractAt("SolidLuxuryNFT", carNFTDeployment.address) as unknown as Contract & { address: string };
  const LuxCoin = await hre.ethers.getContractAt("LuxCoin", carTokenDeployment.address) as unknown as Contract & { address: string };
  const carLeasing = await hre.ethers.getContractAt("CarLeasing", carLeasingDeployment.address) as unknown as Contract & { address: string };

  log("CARNFT deployed to:", SolidLuxuryNFT.address);
  log("LuxCoin deployed to:", LuxCoin.address);
  log("CarLeasing deployed to:", carLeasing.address);
};

export default deployContracts;

deployContracts.tags = ["SolidLuxuryNFT", "LuxCoin", "CarLeasing"];