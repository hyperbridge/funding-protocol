const FundingService = artifacts.require("FundingService");
const FundingVault = artifacts.require("FundingVault");
const ProjectFactory = artifacts.require("ProjectFactory");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(ProjectFactory);
    deployer.deploy(FundingService);
    deployer.deploy(FundingVault, accounts[1]);
};
