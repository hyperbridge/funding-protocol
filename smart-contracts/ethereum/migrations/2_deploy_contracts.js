const FundingService = artifacts.require("FundingService");
const FundingVault = artifacts.require("FundingVault");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(FundingService);
    deployer.deploy(FundingVault, accounts[1]);
};
