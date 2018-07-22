const FundingStorage = artifacts.require("FundingStorage");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const ProjectTimelineProposal = artifacts.require("ProjectTimelineProposal");
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

contract('ProjectTimelineProposal', function(accounts) {
    let fundingStorage;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
    let projectTimelineProposalContract;
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

        projectTimelineProposalContract = await ProjectTimelineProposal.deployed();
        await fundingStorage.registerContract("ProjectTimelineProposal", blankAddress, projectTimelineProposalContract.address);

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
        let projWatcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectId = result.args.projectId;
            }
        });

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, projectMinContributionGoal, projectMaxContributionGoal, projectContributionPeriod, noRefunds, false, { from: developerAccount });

        projWatcher.stopWatching();
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer can propose new timeline", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot propose new timeline unless project is published", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot propose new timeline if there is an active vote for milestone completion", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot propose new timeline if there is an active timeline proposal", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot propose new timeline if pending milestone percentages are invalid", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("project contributor can vote for timeline proposal", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("project contributor can vote against timeline proposal", async () => {
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
    it("developer can finalize timeline proposal", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot finalize timeline proposal if no proposal is active", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer cannot finalize timeline proposal early if approval is less than 75% of total contributors", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // TODO - This will be completed after contribution extensions are completed
    it("developer can finalize timeline proposal early if approval is greater than 75% of total contributors", async () => {
        try {

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
