const FundingStorage = artifacts.require("FundingStorage");
const FundingVault = artifacts.require("FundingVault");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const ProjectTimelineProposal = artifacts.require("ProjectTimelineProposal");
const ProjectMilestoneCompletion = artifacts.require("ProjectMilestoneCompletion");
const Developer = artifacts.require("Developer");
const Curation = artifacts.require("Curation");
const Contribution = artifacts.require("Contribution");

const blankAddress = 0x0000000000000000000000000000000000000000;
const projectTitle = "BlockHub";
const projectDescription = "This is a description of BlockHub.";
const projectAbout = "This is all about BlockHub.";
const projectMinContributionGoal = 1000;
const projectMaxContributionGoal = 10000;
const projectContributionPeriod = 4;
const noRefunds = true;
const noTimeline = true;

contract('ProjectTimelineProposal', function(accounts) {
    let fundingStorage;
    let fundingVault;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
    let projectTimelineProposalContract;
    let projectMilestoneCompletionContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;
    let curationContract;
    let curatorAddress;
    let contributionContract;
    let contributorAccount;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();
        fundingVault = await FundingVault.deployed();
        await fundingStorage.registerContract("FundingVault", blankAddress, fundingVault.address);

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize();

        projectTimelineContract = await ProjectTimeline.deployed();
        await fundingStorage.registerContract("ProjectTimeline", blankAddress, projectTimelineContract.address);

        projectTimelineProposalContract = await ProjectTimelineProposal.deployed();
        await fundingStorage.registerContract("ProjectTimelineProposal", blankAddress, projectTimelineProposalContract.address);

        projectMilestoneCompletionContract = await ProjectMilestoneCompletion.deployed();
        await fundingStorage.registerContract("ProjectMilestoneCompletion", blankAddress, projectMilestoneCompletionContract.address);

        projectContributionTierContract = await ProjectContributionTier.deployed();
        await fundingStorage.registerContract("ProjectContributionTier", blankAddress, projectContributionTierContract.address);

        contributionContract = await Contribution.deployed();
        await fundingStorage.registerContract("Contribution", blankAddress, contributionContract.address);
        contributorAccount = accounts[3];

        curationContract = await Curation.deployed();
        curatorAddress = accounts[2];
        await fundingStorage.registerContract("Curation", blankAddress, curationContract.address);
        await curationContract.setCurationThreshold(1);
        await curationContract.initialize();

        await curationContract.createCurator({ from: curatorAddress });

        developerContract = await Developer.deployed();
        await fundingStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize();

        developerAccount = accounts[1];

        let devWatcher = developerContract.DeveloperCreated().watch(function (error, result) {
            if (!error) {
                developerId = result.args.developerId.toNumber();
            }
        });

        await developerContract.createDeveloper("Hyperbridge", { from: developerAccount });

        devWatcher.stopWatching();
    });

    beforeEach(async () => {
        let projWatcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectId = result.args.projectId;
            }
        });

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, projectMinContributionGoal, projectMaxContributionGoal, projectContributionPeriod, noRefunds, false, { from: developerAccount });

        projWatcher.stopWatching();

        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });
        await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });
        await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });
        await curationContract.curate(projectId, true, { from: curatorAddress });
    });

    it("developer can propose new timeline", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            const proposal = await projectTimelineProposalContract.getTimelineProposal(projectId);

            assert.equal(proposal[3], true, "Proposal should be active.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer cannot propose new timeline unless project is InDevelopment", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot propose new timeline if there is an active vote for milestone completion", async () => {
        try {
            console.log(1);
            await curationContract.publishProject(projectId, { from: developerAccount });
            console.log(1);
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            console.log(1);
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });
            console.log(1);

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            console.log(1);
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            console.log(1);

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, { from: developerAccount });
            console.log(1);

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });
            console.log(1);

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot propose new timeline if there is an active timeline proposal", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot propose new timeline if pending milestone percentages are invalid", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 51, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("project contributor can vote for timeline proposal", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            let proposal = await projectTimelineProposalContract.getTimelineProposal(projectId);
            const initialApprovalCount = proposal[1].toNumber();

            await projectTimelineProposalContract.voteOnTimelineProposal(projectId, true, { from: contributorAccount });

            proposal = await projectTimelineProposalContract.getTimelineProposal(projectId);

            assert.equal(proposal[1].toNumber(), initialApprovalCount + 1, "Vote was not registered.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("project contributor can vote against timeline proposal", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            let proposal = await projectTimelineProposalContract.getTimelineProposal(projectId);
            const initialDisapprovalCount = proposal[2].toNumber();

            await projectTimelineProposalContract.voteOnTimelineProposal(projectId, false, { from: contributorAccount });

            proposal = await projectTimelineProposalContract.getTimelineProposal(projectId);

            assert.equal(proposal[2].toNumber(), initialDisapprovalCount + 1, "Vote was not registered.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("project contributor cannot vote twice", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            await projectTimelineProposalContract.voteOnTimelineProposal(projectId, true, { from: contributorAccount });
            await projectTimelineProposalContract.voteOnTimelineProposal(projectId, true, { from: contributorAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot finalize timeline proposal if no proposal is active", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineProposalContract.finalizeTimelineProposal(projectId, { from: developerAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot finalize timeline proposal early if approval is less than 75% of total contributors", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            await projectTimelineProposalContract.finalizeTimelineProposal(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer can finalize timeline proposal early if approval is greater than 75% of total contributors", async () => {
        try {
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            await projectTimelineProposalContract.voteOnTimelineProposal(projectId, true, { from: contributorAccount });

            await projectTimelineProposalContract.finalizeTimelineProposal(projectId, { from: developerAccount });

            const timelineLength = await projectTimelineContract.getTimelineLength(projectId);

            assert.equal(timelineLength, 2, "Proposed timeline was not moved into active timeline.")
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
