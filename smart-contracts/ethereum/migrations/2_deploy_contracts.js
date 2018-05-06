const Developer = artifacts.require("Developer");
const ProjectFactory = artifacts.require("ProjectFactory");

module.exports = function(deployer) {
    deployer.deploy(Developer, "Hyperbridge");
    deployer.deploy(ProjectFactory);
};
