const FundingStorage = artifacts.require("FundingStorage");
const ProjectStorageAccess = artifacts.require("ProjectStorageAccess");
const DeveloperStorageAccess = artifacts.require("DeveloperStorageAccess");
const ContributionStorageAccess = artifacts.require("ContributionStorageAccess");

const ProjectBase = artifacts.require("ProjectBase");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const ProjectMilestoneCompletion = artifacts.require("ProjectMilestoneCompletion");
const ProjectTimelineProposal = artifacts.require("ProjectTimelineProposal");

const ProjectHelpersLibrary = artifacts.require("ProjectHelpersLibrary");

const Contribution = artifacts.require("Contribution");

const Developer = artifacts.require("Developer");

async function doDeploy(deployer, network) {
    await deployer.deploy(FundingStorage);
    const fs = await FundingStorage.deployed();

    await deployer.deploy(ProjectStorageAccess);
    await deployer.link(ProjectStorageAccess, [ProjectBase, ProjectHelpersLibrary, Contribution]);

    await deployer.deploy(DeveloperStorageAccess);
    await deployer.link(DeveloperStorageAccess, [Developer, ProjectBase]);

    await deployer.deploy(ContributionStorageAccess);
    await deployer.link(ContributionStorageAccess, [Contribution, ProjectBase]);

    await deployer.deploy(ProjectHelpersLibrary);
    await deployer.link(ProjectHelpersLibrary, [ProjectTimelineProposal, ProjectRegistration, ProjectMilestoneCompletion]);

    await deployer.deploy(ProjectRegistration, fs.address);
    await deployer.deploy(ProjectTimeline, fs.address);
    await deployer.deploy(ProjectContributionTier, fs.address);
    await deployer.deploy(ProjectMilestoneCompletion, fs.address);
    await deployer.deploy(ProjectTimelineProposal, fs.address);

    await deployer.deploy(Developer, fs.address);
    await deployer.deploy(Contribution, fs.address);
}

module.exports = function(deployer, network) {
    deployer.then(async () => {
        await doDeploy(deployer, network);
    });
};
