const FundingService = artifacts.require("FundingService");
const Bounty = artifacts.require("Bounty");

module.exports = function(deployer) {
    deployer.deploy(FundingService);
};

// module.exports = function(deployer) {
//     deployer.deploy(Bounty, "Maple", "Greatest Bug In Existence", "http://dailyhive.com");
// };

