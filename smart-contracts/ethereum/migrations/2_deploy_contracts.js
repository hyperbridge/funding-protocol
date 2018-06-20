const FundingService = artifacts.require("FundingService");
const ProjectFactory = artifacts.require("ProjectFactory");

module.exports = function(deployer) {
    deployer.deploy(ProjectFactory);
    deployer.deploy(FundingService);
};

