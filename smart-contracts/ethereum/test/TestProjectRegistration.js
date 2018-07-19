const FundingStorage = artifacts.require("FundingStorage");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const Developer = artifacts.require("Developer");

const blankAddress = 0x0000000000000000000000000000000000000000;
const projectTitle = "BlockHub";
const projectDescription = "This is a description of BlockHub.";
const projectAbout = "This is all about BlockHub.";
const projectContributionGoal = 1000;
const noRefunds = true;
const noTimeline = true;

contract('ProjectCreation', function(accounts) {
    let fundingStorage;
    let projectRegistrationContract;
    let developerContract;
    let developerAccount;
    let developerId;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize(fundingStorage.address);

        developerContract = await Developer.deployed();
        await fundingStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize(fundingStorage.address);

        developerAccount = accounts[1];

        let watcher = developerContract.DeveloperCreated().watch(function (error, result) {
            if (!error) {
                developerId = result.args.developerId;
            }
        });

        await developerContract.createDeveloper("Hyperbridge", { from: developerAccount });

        watcher.stopWatching();
    });

    it("developer should be able to create a project", async () => {
        try {
            let projectId;

            let watcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
                if (!error) {
                    projectId = result.args.projectId;
                }
            });

            await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, projectContributionGoal, noRefunds, noTimeline, { from: developerAccount });

            watcher.stopWatching();

            const project = await projectRegistrationContract.getProject(projectId);

            assert.notEqual(project[0], 0, "Project ID 0 should be reserved.");
            assert.equal(project[0].toNumber(), projectId, "Project ID is incorrect.");
            assert.equal(project[1].toNumber(), 0, "Project should be set to Status: Draft.");
            assert.equal(project[2], projectTitle, "Project title is incorrect.");
            assert.equal(project[3], projectDescription, "Project description is incorrect.");
            assert.equal(project[4], projectAbout, "Project about is incorrect.");
            assert.equal(project[5].toNumber(), projectContributionGoal, "Project contribution goal is incorrect.");
            assert.equal(project[6], noRefunds, "Project should not be set to no refunds.");
            assert.equal(project[7], noTimeline, "Project should not be set to no timeline.");
            assert.equal(project[8], developerAccount, "Project developer is incorrect.");
            assert.equal(project[9].toNumber(), developerId, "Project developer ID is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-developer should not be able to create a project", async () => {
        try {
            await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, projectContributionGoal, noRefunds, noTimeline, { from: accounts[2] });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});

contract('ProjectEditing', function(accounts) {
    let fundingStorage;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize(fundingStorage.address);

        projectTimelineContract = await ProjectTimeline.deployed();
        await fundingStorage.registerContract("ProjectTimeline", blankAddress, projectTimelineContract.address);

        projectContributionTierContract = await ProjectContributionTier.deployed();
        await fundingStorage.registerContract("ProjectContributionTier", blankAddress, projectContributionTierContract.address);

        developerContract = await Developer.deployed();
        await fundingStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize(fundingStorage.address);

        developerAccount = accounts[1];

        let devWatcher = developerContract.DeveloperCreated().watch(function (error, result) {
            if (!error) {
                developerId = result.args.developerId;
            }
        });

        await developerContract.createDeveloper("Hyperbridge", { from: developerAccount });

        devWatcher.stopWatching();

        let projWatcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectId = result.args.projectId;
            }
        });

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, projectContributionGoal, noRefunds, noTimeline, { from: developerAccount });

        projWatcher.stopWatching();
    });

    it("project developer should be able to edit a draft project", async () => {
        const newTitle = "New BlockHub";
        const newDescription = "This is a new description of BlockHub.";
        const newAbout = "This is all about New BlockHub.";
        const newContributionGoal = 2000;
        const newNoRefunds = false;
        const newNoTimeline = false;
        
        try {
            await projectRegistrationContract.editProject(projectId, newTitle, newDescription, newAbout, newContributionGoal, newNoRefunds, newNoTimeline, { from: developerAccount });

            const project = await projectRegistrationContract.getProject(projectId);

            assert.notEqual(project[0].toNumber(), 0, "Project ID 0 should be reserved.");
            assert.equal(project[0].toNumber(), projectId, "Project ID is incorrect.");
            assert.equal(project[1].toNumber(), 0, "Project should be set to Status: Draft.");
            assert.equal(project[2], newTitle, "Project title is incorrect.");
            assert.equal(project[3], newDescription, "Project description is incorrect.");
            assert.equal(project[4], newAbout, "Project about is incorrect.");
            assert.equal(project[5].toNumber(), newContributionGoal, "Project contribution goal is incorrect.");
            assert.equal(project[6], newNoRefunds, "Project should not be set to no refunds.");
            assert.equal(project[7], newNoTimeline, "Project should not be set to no timeline.");
            assert.equal(project[8], developerAccount, "Project developer is incorrect.");
            assert.equal(project[9].toNumber(), developerId, "Project developer ID is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-project developer should not be able to edit a draft project", async () => {
        const newTitle = "New Improved BlockHub";
        const newDescription = "This is a new improved description of BlockHub.";
        const newAbout = "This is all about New Improved BlockHub.";
        const newContributionGoal = 3000;
        const newNoRefunds = true;
        const newNoTimeline = true;
        
        try {
            await projectRegistrationContract.editProject(projectId, newTitle, newDescription, newAbout, newContributionGoal, newNoRefunds, newNoTimeline, { from: accounts[2] });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
    
    it("project developer should not be able to edit a non-draft project", async () => {
        const newTitle = "New Improved BlockHub";
        const newDescription = "This is a new improved description of BlockHub.";
        const newAbout = "This is all about New Improved BlockHub.";
        const newContributionGoal = 3000;
        const newNoRefunds = true;
        const newNoTimeline = true;

        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });
            await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            await projectRegistrationContract.editProject(projectId, newTitle, newDescription, newAbout, newContributionGoal, newNoRefunds, newNoTimeline, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});

contract('ProjectReview', function(accounts) {
    let fundingStorage;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize(fundingStorage.address);

        projectTimelineContract = await ProjectTimeline.deployed();
        await fundingStorage.registerContract("ProjectTimeline", blankAddress, projectTimelineContract.address);

        projectContributionTierContract = await ProjectContributionTier.deployed();
        await fundingStorage.registerContract("ProjectContributionTier", blankAddress, projectContributionTierContract.address);

        developerContract = await Developer.deployed();
        await fundingStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize(fundingStorage.address);

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

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, projectContributionGoal, noRefunds, false, { from: developerAccount });

        projWatcher.stopWatching();
    });

    it("project can be submitted for review", async () => {
        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });
            await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });

            let initialPendingContributionTiersLength = await projectContributionTierContract.getPendingContributionTiersLength(projectId);
            let initialPendingTimelineLength = await projectTimelineContract.getPendingTimelineLength(projectId);

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            let newPendingContributionTiersLength = await projectContributionTierContract.getPendingContributionTiersLength(projectId);
            let newContributionTiersLength = await projectContributionTierContract.getContributionTiersLength(projectId);

            let newPendingTimelineLength = await projectTimelineContract.getPendingTimelineLength(projectId);
            let newTimelineLength = await projectTimelineContract.getTimelineLength(projectId);

            assert.equal(newPendingContributionTiersLength.toNumber(), 0, "Pending contribution tiers were not removed.");
            assert.equal(newContributionTiersLength.toNumber(), initialPendingContributionTiersLength.toNumber(), "Pending contribution tiers were not moved into active tiers.");
            assert.equal(newPendingTimelineLength.toNumber(), 0, "Pending timeline was not removed.");
            assert.equal(newTimelineLength.toNumber(), initialPendingTimelineLength.toNumber(), "Pending milestones were not moved into active timeline.");

            const project = await projectRegistrationContract.getProject(projectId);
            assert.equal(project[1].toNumber(), 1, "Project should be set to Status: Pending.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("project with no tiers cannot be submitted for review", async () => {
        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);

            const project = await projectRegistrationContract.getProject(projectId);

            assert.equal(project[1].toNumber(), 0, "Project status should still be Status: Pending.");
        }
    });

    it("project with invalid milestones cannot be submitted for review", async () => {
        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 99, { from: developerAccount });
            await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);

            const project = await projectRegistrationContract.getProject(projectId);

            assert.equal(project[1].toNumber(), 0, "Project status should still be Status: Pending.");
        }
    });
});
