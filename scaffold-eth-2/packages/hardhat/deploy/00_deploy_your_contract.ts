import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "ethers";
import { Contract } from "ethers";
const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, log } = hre.deployments;
  let ethers = require('../node_modules/ethers')
  log("Deploying CARNFT contract...");
  const carNFTDeployment = await deploy("CARNFT", {
    from: deployer,
    args: ["CARNFT","CRNFT",deployer],
    log: true,
    autoMine: true,
  });

  log("Deploying CarToken contract...");
  const carTokenDeployment = await deploy("CarToken", {
    from: deployer,
    args: [],
    log: true,
    autoMine: true,
  });

  log("Deploying CarLeasing contract...");
  const carLeasingDeployment = await deploy("CarLeasing", {
    from: deployer,
    args: [carNFTDeployment.address, carTokenDeployment.address, 1, deployer], // rentalRatePerSecond set to 1 (adjust as necessary), deployer is the rent wallet
    log: true,
    autoMine: true,
  });

  // Get the deployed contracts to interact with them after deploying
  // Get the deployed contracts to interact with them after deploying
  const carNFT = await hre.ethers.getContractAt("CARNFT", carNFTDeployment.address) as unknown as Contract & { address: string };
  const carToken = await hre.ethers.getContractAt("CarToken", carTokenDeployment.address) as unknown as Contract & { address: string };
  const carLeasing = await hre.ethers.getContractAt("CarLeasing", carLeasingDeployment.address) as unknown as Contract & { address: string };

  log("CARNFT deployed to:", carNFT.address);
  log("CarToken deployed to:", carToken.address);
  log("CarLeasing deployed to:", carLeasing.address);
};

export default deployContracts;

deployContracts.tags = ["CARNFT", "CarToken", "CarLeasing"];