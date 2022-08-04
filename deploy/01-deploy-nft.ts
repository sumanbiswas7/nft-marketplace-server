import { artifacts } from "hardhat";
import { DeployFunction, DeployResult } from "hardhat-deploy/types";
import fs from "fs";

const deployFunction: DeployFunction = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    const nft = await deploy("NFT", {
        from: deployer,
        log: true,
        waitConfirmations: 1
    })

    console.log("---------------------------------------")
    saveFrontendFiles(nft, "NFT");
}

function saveFrontendFiles(contract: DeployResult, name: string) {
    const contractsDir = __dirname + "/../../client/contractsData";
    const contractArtifact = artifacts.readArtifactSync(name);

    if (!fs.existsSync(contractsDir)) fs.mkdirSync(contractsDir);

    fs.writeFileSync(
        contractsDir + `/${name}-address.json`,
        JSON.stringify({ address: contract.address }, undefined, 2)
    );
    fs.writeFileSync(
        contractsDir + `/${name}.json`,
        JSON.stringify(contractArtifact, null, 2)
    );
}

deployFunction.tags = ["all", "nft"]
export default deployFunction;
