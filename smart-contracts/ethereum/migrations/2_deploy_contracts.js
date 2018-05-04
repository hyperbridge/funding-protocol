const Developer = artifacts.require("Developer");

module.exports = function(deployer) {
    deployer.deploy(Developer, "Hyperbridge");
};
