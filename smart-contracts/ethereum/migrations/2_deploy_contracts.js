const FundingStorage = artifacts.require("FundingStorage");
const ProjectStorageAccess = artifacts.require("ProjectStorageAccess");
const DeveloperStorageAccess = artifacts.require("DeveloperStorageAccess");
const ContributionStorageAccess = artifacts.require("ContributionStorageAccess");
const CurationStorageAccess = artifacts.require("CurationStorageAccess");

const ProjectBase = artifacts.require("ProjectBase");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const ProjectMilestoneCompletion = artifacts.require("ProjectMilestoneCompletion");
const ProjectTimelineProposal = artifacts.require("ProjectTimelineProposal");

const ProjectHelpersLibrary = artifacts.require("ProjectHelpersLibrary");

const Contribution = artifacts.require("Contribution");

const Developer = artifacts.require("Developer");

const Curation = artifacts.require("Curation");

async function doDeploy(deployer, network) {
    await deployer.deploy(FundingStorage);
    const fs = await FundingStorage.deployed();

    await deployer.deploy(ProjectStorageAccess);
    await deployer.link(ProjectStorageAccess, [ProjectBase, ProjectHelpersLibrary, Contribution, Curation]);

    await deployer.deploy(DeveloperStorageAccess);
    await deployer.link(DeveloperStorageAccess, [Developer, ProjectBase]);

    await deployer.deploy(ContributionStorageAccess);
    await deployer.link(ContributionStorageAccess, [Contribution, ProjectBase]);

    await deployer.deploy(CurationStorageAccess);
    await deployer.link(CurationStorageAccess, Curation);

    await deployer.deploy(ProjectHelpersLibrary);
    await deployer.link(ProjectHelpersLibrary, [ProjectTimelineProposal, ProjectRegistration, ProjectMilestoneCompletion]);

    await deployer.deploy(ProjectRegistration);
    await deployer.deploy(ProjectTimeline, fs.address);
    await deployer.deploy(ProjectContributionTier, fs.address);
    await deployer.deploy(ProjectMilestoneCompletion, fs.address);
    await deployer.deploy(ProjectTimelineProposal, fs.address);

    await deployer.deploy(Developer);
    await deployer.deploy(Contribution);
    await deployer.deploy(Curation);
}

module.exports = function(deployer, network) {
    deployer.then(async () => {
        await doDeploy(deployer, network);
    });
};
