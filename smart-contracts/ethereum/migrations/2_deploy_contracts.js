const FundingService = artifacts.require("FundingService");

module.exports = function(deployer) {
    deployer.deploy(FundingService);
};

