const FundingStorage = artifacts.require("FundingStorage");

const Project = artifacts.require("Project");
const ProjectStorageAccess = artifacts.require("ProjectStorageAccess");
const ProjectLib = artifacts.require("ProjectLib");
const ProjectTimelineLib = artifacts.require("ProjectTimelineLib");
const ProjectContributionTierLib = artifacts.require("ProjectContributionTierLib");
const ProjectMilestoneCompletionLib = artifacts.require("ProjectMilestoneCompletionLib");
const ProjectTimelineProposalLib = artifacts.require("ProjectTimelineProposalLib");

const Contribution = artifacts.require("Contribution");
const ContributionStorageAccess = artifacts.require("ContributionStorageAccess");

const Developer = artifacts.require("Developer");
const DeveloperStorageAccess = artifacts.require("DeveloperStorageAccess");

async function doDeploy(deployer, network) {
    await deployer.deploy(FundingStorage);
    const fs = await FundingStorage.deployed();

    await deployer.deploy(ProjectStorageAccess);
    await deployer.link(ProjectStorageAccess, [Project, Contribution, ProjectLib, ProjectContributionTierLib, ProjectMilestoneCompletionLib, ProjectTimelineLib, ProjectTimelineProposalLib]);

    await deployer.deploy(ContributionStorageAccess);
    await deployer.link(ContributionStorageAccess, [Contribution, Project]);

    await deployer.deploy(DeveloperStorageAccess);
    await deployer.link(DeveloperStorageAccess, [Developer, Project]);

    await deployer.deploy(ProjectLib);
    await deployer.link(ProjectLib, Project);

    await deployer.deploy(ProjectContributionTierLib);
    await deployer.link(ProjectContributionTierLib, Project);

    await deployer.deploy(ProjectMilestoneCompletionLib);
    await deployer.link(ProjectMilestoneCompletionLib, Project);

    await deployer.deploy(ProjectTimelineLib);
    await deployer.link(ProjectTimelineLib, Project);

    await deployer.deploy(ProjectTimelineProposalLib);
    await deployer.link(ProjectTimelineProposalLib, Project);

    await deployer.deploy(Project, fs.address);
}

module.exports = function(deployer, network) {
    deployer.then(async () => {
        await doDeploy(deployer, network);
    });
};
