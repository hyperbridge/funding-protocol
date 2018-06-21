//const FundingService = artifacts.require("FundingService");
//const Bounty = artifacts.require("Bounty");
const BountyService = artifacts.require("BountyService");
const strings = artifacts.require("strings");

module.exports = function(deployer) {
    //deployer.deploy(FundingService);
    //deployer.deploy(Bounty, "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", 1 , "Maple", "Greatest Bug In Existence", "http://dailyhive.com");
    deployer.deploy(strings);
    deployer.deploy(BountyService);    
};

// module.exports = function(deployer) {
//     deployer.deploy(Bounty, "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", 1 , "Maple", "Greatest Bug In Existence", "http://dailyhive.com");
// };

