const FundingStorage = artifacts.require("FundingStorage");
const FundingVault = artifacts.require("FundingVault");

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

const ProjectTimelineHelpersLibrary = artifacts.require("ProjectTimelineHelpersLibrary");
const ProjectContributionTierHelpersLibrary = artifacts.require("ProjectContributionTierHelpersLibrary");

const Contribution = artifacts.require("Contribution");

const Developer = artifacts.require("Developer");

const Curation = artifacts.require("Curation");

async function doDeploy(deployer, network) {
    await deployer.deploy(FundingStorage);
    const fs = await FundingStorage.deployed();

    await deployer.deploy(FundingVault, fs.address);

    await deployer.deploy(ProjectStorageAccess);
    await deployer.link(ProjectStorageAccess, [ProjectBase, ProjectTimelineHelpersLibrary, ProjectContributionTierHelpersLibrary, Contribution, Curation]);

    await deployer.deploy(DeveloperStorageAccess);
    await deployer.link(DeveloperStorageAccess, [Developer, ProjectBase]);

    await deployer.deploy(ContributionStorageAccess);
    await deployer.link(ContributionStorageAccess, [Contribution, ProjectBase]);

    await deployer.deploy(CurationStorageAccess);
    await deployer.link(CurationStorageAccess, Curation);

    await deployer.deploy(ProjectTimelineHelpersLibrary);
    await deployer.link(ProjectTimelineHelpersLibrary, [ProjectTimelineProposal, ProjectRegistration, ProjectMilestoneCompletion]);

    await deployer.deploy(ProjectContributionTierHelpersLibrary);
    await deployer.link(ProjectContributionTierHelpersLibrary, ProjectRegistration);

    await deployer.deploy(ProjectRegistration, fs.address, true);
    await deployer.deploy(ProjectTimeline, fs.address, true);
    await deployer.deploy(ProjectContributionTier, fs.address, true);
    await deployer.deploy(ProjectMilestoneCompletion, fs.address, true);
    await deployer.deploy(ProjectTimelineProposal, fs.address, true);

    await deployer.deploy(Developer, fs.address, true);
    await deployer.deploy(Contribution, fs.address, true);
    await deployer.deploy(Curation, fs.address, true);
}

module.exports = function(deployer, network) {
    deployer.then(async () => {
        await doDeploy(deployer, network);
    });
};
