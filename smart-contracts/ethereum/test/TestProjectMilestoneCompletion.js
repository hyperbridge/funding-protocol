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
const projectMinContributionGoal = 1000000000000000000;
const projectMaxContributionGoal = 5000000000000000000;
const projectContributionPeriod = 4;
const noRefunds = true;
const noTimeline = true;
const milestoneReport = "Report!";

contract('ProjectMilestoneCompletion', function(accounts) {
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

        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 20, { from: developerAccount });
        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 30, { from: developerAccount });
        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
        await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });
        await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });
        await curationContract.curate(projectId, true, { from: curatorAddress });
        await curationContract.publishProject(projectId, { from: developerAccount });
        await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
    });

    it("developer can submit milestone completion", async () => {
        const milestoneReport = "This milestone is done.";

        try {
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });

            const milestoneCompletionSubmission = await projectMilestoneCompletionContract.getMilestoneCompletionSubmission(projectId);

            assert.equal(milestoneCompletionSubmission[1].toNumber(), 0, "Approval count should be 0 to begin.");
            assert.equal(milestoneCompletionSubmission[2].toNumber(), 0, "Disapproval count should be 0 to begin.");
            assert.equal(milestoneCompletionSubmission[3], milestoneReport, "Milestone report is incorrect.");
            assert.equal(milestoneCompletionSubmission[4], true, "Milestone completion submission should be active.");
            assert.equal(milestoneCompletionSubmission[5], false, "Milestone completion submission should not have failed yet.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer cannot submit milestone completion unless project is published", async () => {
        try {
            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot submit milestone completion if there is an active vote for milestone completion", async () => {
        try {
            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });
            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });


    it("developer cannot submit milestone completion if there is an active timeline proposal", async () => {
        try {
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("project contributor can vote for milestone completion", async () => {
        try {
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });

            let submission = await projectMilestoneCompletionContract.getMilestoneCompletionSubmission(projectId);
            const initialApprovalCount = submission[1].toNumber();

            await projectMilestoneCompletionContract.voteOnMilestoneCompletion(projectId, true, { from: contributorAccount });

            submission = await projectMilestoneCompletionContract.getMilestoneCompletionSubmission(projectId);
            const newApprovalCount = submission[1].toNumber();

            assert.equal(newApprovalCount, initialApprovalCount + 1, "Vote was not registered.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("project contributor can vote against milestone completion", async () => {
        try {
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });

            let submission = await projectMilestoneCompletionContract.getMilestoneCompletionSubmission(projectId);
            const initialDisapprovalCount = submission[2].toNumber();

            await projectMilestoneCompletionContract.voteOnMilestoneCompletion(projectId, false, { from: contributorAccount });

            submission = await projectMilestoneCompletionContract.getMilestoneCompletionSubmission(projectId);
            const newDisapprovalCount = submission[2].toNumber();

            assert.equal(newDisapprovalCount, initialDisapprovalCount + 1, "Vote was not registered.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("project contributor cannot vote twice", async () => {
        try {
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });

            await projectMilestoneCompletionContract.voteOnMilestoneCompletion(projectId, true, { from: contributorAccount });
            await projectMilestoneCompletionContract.voteOnMilestoneCompletion(projectId, true, { from: contributorAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer can finalize milestone completion - success", async () => {
        try {
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });

            await projectMilestoneCompletionContract.voteOnMilestoneCompletion(projectId, true, { from: contributorAccount });

            const initialDeveloperFunds = web3.eth.getBalance(developerAccount).toNumber();
            const projectFundsRaised = await contributionContract.getProjectFundsRaised(projectId);

            await projectMilestoneCompletionContract.finalizeMilestoneCompletion(projectId, { from: developerAccount });

            const submission = await projectMilestoneCompletionContract.getMilestoneCompletionSubmission(projectId);
            const submissionIsActive = submission[4];
            const submissionHasFailed = submission[5];
            assert.equal(submissionIsActive, false, "Submission should no longer be active.");
            assert.equal(submissionHasFailed, false, "Submission should not have failed.");

            const milestone = await projectTimelineContract.getTimelineMilestone(projectId, 0);
            const milestoneIsComplete = milestone[3];
            assert.equal(milestoneIsComplete, true, "Milestone should be complete.");

            const nextMilestone = await projectTimelineContract.getTimelineMilestone(projectId, 1);
            const percentage = nextMilestone[2].toNumber();
            const fundsSent = projectFundsRaised * percentage / 100;

            const newDeveloperFunds = web3.eth.getBalance(developerAccount).toNumber();

            assert.closeTo(newDeveloperFunds, initialDeveloperFunds + fundsSent, 50000000000000000, "Developer balance incorrect after milestone completion.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer cannot finalize milestone completion if no submission is active", async () => {
        try {
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectMilestoneCompletionContract.finalizeMilestoneCompletion(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot finalize milestone completion early if approval is less than 75% of total contributors", async () => {
        try {
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, milestoneReport, { from: developerAccount });

            await projectMilestoneCompletionContract.voteOnMilestoneCompletion(projectId, false, { from: contributorAccount });

            await projectMilestoneCompletionContract.finalizeMilestoneCompletion(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
