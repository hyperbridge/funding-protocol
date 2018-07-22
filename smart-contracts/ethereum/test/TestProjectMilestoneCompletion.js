const FundingStorage = artifacts.require("FundingStorage");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const ProjectMilestoneCompletion = artifacts.require("ProjectMilestoneCompletion");
const Developer = artifacts.require("Developer");

const blankAddress = 0x0000000000000000000000000000000000000000;
const projectTitle = "BlockHub";
const projectDescription = "This is a description of BlockHub.";
const projectAbout = "This is all about BlockHub.";
const projectMinContributionGoal = 1000;
const projectMaxContributionGoal = 10000;
const projectContributionPeriod = 4;
const noRefunds = true;
const noTimeline = true;

contract('ProjectMilestoneCompletion', function(accounts) {
    let fundingStorage;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
    let projectMilestoneCompletionContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize();

        projectTimelineContract = await ProjectTimeline.deployed();
        await fundingStorage.registerContract("ProjectTimeline", blankAddress, projectTimelineContract.address);

        projectContributionTierContract = await ProjectContributionTier.deployed();
        await fundingStorage.registerContract("ProjectContributionTier", blankAddress, projectContributionTierContract.address);

        projectMilestoneCompletionContract = await ProjectMilestoneCompletion.deployed();
        await fundingStorage.registerContract("ProjectMilestoneCompletion", blankAddress, projectMilestoneCompletionContract.address);

        developerContract = await Developer.deployed();
        await fundingStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize();

        developerAccount = accounts[1];

        let devWatcher = developerContract.DeveloperCreated().watch(function (error, result) {
            if (!error) {
                developerId = result.args.developerId;
            }
        });

        await developerContract.createDeveloper("Hyperbridge", { from: developerAccount });

        devWatcher.stopWatching();
    });

    beforeEach(async () => {
        const contributorLimit = 1000;
        const maxContribution = 100;
        const minContribution = 10;
        const rewards = "Rewards!";

        const milestoneTitle = "Milestone Title";
        const milestoneDescription = "Milestone Description";
        const milestonePercentage = 50;

        let projWatcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectId = result.args.projectId;
            }
        });

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, projectMinContributionGoal, projectMaxContributionGoal, projectContributionPeriod, noRefunds, false, { from: developerAccount });

        projWatcher.stopWatching();

        await projectContributionTierContract.addContributionTier(projectId, contributorLimit, maxContribution, minContribution, rewards, { from: developerAccount });

        await projectTimelineContract.addMilestone(projectId, milestoneTitle, milestoneDescription, milestonePercentage, { from: developerAccount });
        await projectTimelineContract.addMilestone(projectId, milestoneTitle, milestoneDescription, milestonePercentage, { from: developerAccount });

        await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });
    });

    it("developer can submit milestone completion", async () => {
        const milestoneReport = "This milestone is done.";

        try {
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

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot submit milestone completion unless project is published", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot submit milestone completion if there is an active vote for milestone completion", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });


    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot submit milestone completion if there is an active timeline proposal", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("project contributor can vote for milestone completion", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("project contributor can vote against milestone completion", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("project contributor cannot vote twice", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer can finalize milestone completion", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot finalize milestone completion if no submission is active", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot finalize milestone completion early if approval is less than 75% of total contributors", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer can finalize milestone completion early if approval is greater than 75% of total contributors", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
