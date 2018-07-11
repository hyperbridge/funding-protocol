const FundingService = artifacts.require("FundingService");
const ProjectEternalStorage = artifacts.require("ProjectEternalStorage");
const ProjectLib = artifacts.require("ProjectLib");
const ProjectContributionTierLib = artifacts.require("ProjectContributionTierLib");
const ProjectMilestoneCompletionLib = artifacts.require("ProjectMilestoneCompletionLib");
const ProjectStorageAccess = artifacts.require("ProjectStorageAccess");
const ProjectTimelineLib = artifacts.require("ProjectTimelineLib");
const ProjectTimelineProposalLib = artifacts.require("ProjectTimelineProposalLib");
const Project = artifacts.require("Project");

async function doDeploy(deployer, network) {
    await deployer.deploy(FundingService);

    await deployer.deploy(ProjectEternalStorage);

    const fs = await FundingService.deployed();

    await deployer.deploy(ProjectStorageAccess);
    await deployer.link(ProjectStorageAccess, [Project, ProjectLib, ProjectContributionTierLib, ProjectMilestoneCompletionLib, ProjectTimelineLib, ProjectTimelineProposalLib]);

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
