const FundingService = artifacts.require("FundingService");
const Project = artifacts.require("Project");
const ProjectEternalStorage = artifacts.require("ProjectEternalStorage");

contract('FundingService', function(accounts) {
    let fundingService;
    let projectStorage;
    let fundingServiceOwner;
    let devAccount;
    let project;
    let projectId;
    let projectDevId;
    const devName = "Hyperbridge";
    const projectTitle = "Blockhub";
    const projectDescription = "This is a description of Blockhub.";
    const projectAbout = "These are the various features of Blockhub.";
    const projectContributionGoal = 1000000;

    before(async () => {
        fundingService = await FundingService.deployed();
        fundingServiceOwner = accounts[0];
        devAccount = accounts[1];

        projectStorage = await ProjectEternalStorage.deployed();

        project = await Project.deployed();
        await project.registerProjectStorage(projectStorage.address);

        await fundingService.registerProjectContract(project.address);

        await fundingService.createDeveloper(devName, { from: devAccount });

        projectDevId = await fundingService.developerMap.call(devAccount);
    });

    beforeEach(async () => {
        let watcher = fundingService.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectId = result.args.projectId;
            }
        });

        await fundingService.createProject(projectTitle, projectDescription, projectAbout, projectDevId, projectContributionGoal, {from: devAccount});

        watcher.stopWatching();
    });

    it("should deploy a FundingService contract", async () => {
        try {
            assert.ok(fundingService.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to create a Developer", async () => {
       try {
           const newDeveloperId = await fundingService.developerMap.call(devAccount);
           assert.equal(newDeveloperId, 1, "New developer should be in developerMap with id = 1");

           const createdDeveloper = await fundingService.developers.call(newDeveloperId);

           assert.equal(createdDeveloper[0].toNumber(), newDeveloperId, "Incorrect ID");
           assert.equal(createdDeveloper[2], devAccount, "Incorrect address");
           assert.equal(createdDeveloper[3], devName, "Incorrect name");
       } catch (e) {
           console.log(e.message);
           assert.fail();
       }
    });

    it("should be able to create Project", async () => {
        try {
            const createdProject = await project.getProject(projectId);

            const createdProjectIsActive = createdProject[0];
            const createdProjectStatus = createdProject[1];
            const createdProjectTitle = createdProject[2];
            const createdProjectDescription = createdProject[3];
            const createdProjectAbout = createdProject[4];
            const createdProjectContributionGoal = createdProject[5];
            const createdProjectDeveloper = createdProject[6];
            const createdProjectDeveloperId = createdProject[7];

            assert.equal(createdProjectIsActive, true);
            assert.equal(createdProjectStatus.toNumber(), 0);
            assert.equal(createdProjectTitle, projectTitle);
            assert.equal(createdProjectDescription, projectDescription);
            assert.equal(createdProjectAbout, projectAbout);
            assert.equal(createdProjectDeveloper, devAccount);
            assert.equal(createdProjectDeveloperId.toNumber(), projectDevId);
            assert.equal(createdProjectContributionGoal.toNumber(), projectContributionGoal);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should reject Project creation from wrong account", async () => {
        try {
            const title = "New Project";
            const description = "This is a description of New Project.";
            const about = "These are the various features of New Project.";
            const developerId = await fundingService.developerMap.call(devAccount);
            const contributionGoal = 1000000;

            await fundingService.createProject(title, description, about, developerId, contributionGoal, {from: accounts[2]});

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    // TODO
    // it("should submit project for review", async () => {
    //     try {
    //         await project.addMilestone("Title 1", "Description 1", 30, false, { from: devAccount });
    //         await project.addMilestone("Title 2", "Description 2", 50, false, { from: devAccount });
    //         await project.addMilestone("Title 3", "Description 3", 20, false, { from: devAccount });
    //
    //         await project.addTier(1000, 10000, 500, "These are the rewards.", { from: devAccount });
    //         await project.addTier(500, 499, 1, "More rewards!", { from: devAccount });
    //         await project.finalizeTiers({ from: devAccount });
    //
    //         await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });
    //
    //         const projectStatus = await project.status.call();
    //
    //         assert.equal(projectStatus, 1, "FundingService did not change valid project's status to Pending.");
    //     } catch (e) {
    //         console.log(e.message);
    //         assert.fail();
    //     }
    // });

    it("should reject project submitted for review with invalid milestones", async () => {
        try {
            await project.addMilestone("Title 1", "Description 1", 30, false, { from: devAccount });
            await project.addMilestone("Title 2", "Description 2", 50, false, { from: devAccount });
            await project.addMilestone("Title 3", "Description 3", 21, false, { from: devAccount });

            await project.addTier(1000, 10000, 500, "These are the rewards.", { from: devAccount });
            await project.addTier(500, 499, 1, "More rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should reject project submitted for review with no contribution tiers", async () => {
        try {
            await project.addMilestone("Title 1", "Description 1", 30, false, { from: devAccount });
            await project.addMilestone("Title 2", "Description 2", 50, false, { from: devAccount });
            await project.addMilestone("Title 3", "Description 3", 20, false, { from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should accept project submitted for review with no milestones if it has noTimeline term set", async () => {
        try {
            await project.setNoTimeline(true, { from: devAccount });

            await project.addTier(1000, 10000, 500, "These are the rewards.", { from: devAccount });
            await project.addTier(500, 499, 1, "More rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            const projectStatus = await project.status.call();
            const projectTimelineIsActive = await project.getTimelineIsActive.call();

            assert.equal(projectStatus, 1, "FundingService did not change valid project's status to Pending.");
            assert.ok(projectTimelineIsActive);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("new contributor should be able to contribute to a project", async function() {
        try {
            const amountToContribute = 1000;

            const initialProjectBalance = await web3.eth.getBalance(projectAddress);
            const initialContributionAmount = await fundingService.projectContributionAmount.call(projectAddress, accounts[2]);

            assert.equal(initialContributionAmount, 0, "Initial contribution amount should be 0");

            let projectContributors = await fundingService.getProjectContributorList(projectAddress);
            const initialProjectContributorsLength = projectContributors.length;

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: amountToContribute });

            const finalProjectBalance = await web3.eth.getBalance(projectAddress);
            const finalContributionAmount = await fundingService.projectContributionAmount.call(projectAddress, accounts[2]);
            projectContributors = await fundingService.getProjectContributorList(projectAddress);
            const finalProjectContributorsLength = projectContributors.length;

            assert.equal(finalProjectBalance.toNumber(), initialProjectBalance.toNumber() + amountToContribute, "Project contract balance incorrect");
            assert.equal(finalContributionAmount.toNumber(), initialContributionAmount.toNumber() + amountToContribute, "FundingService record of this addresses contribution amount incorrect");
            assert.equal(finalProjectContributorsLength, initialProjectContributorsLength + 1, "Project contributors length incorrect");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("existing contributor should be able to contribute to a project", async function() {
        try {
            const amountToContribute = 1000;

            const initialProjectBalance = await web3.eth.getBalance(projectAddress);
            const initialContributionAmount = await fundingService.projectContributionAmount.call(projectAddress, accounts[2]);

            let projectContributors = await fundingService.getProjectContributorList(projectAddress);
            const initialProjectContributorsLength = projectContributors.length;

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: amountToContribute });

            const finalProjectBalance = await web3.eth.getBalance(projectAddress);
            const finalContributionAmount = await fundingService.projectContributionAmount.call(projectAddress, accounts[2]);
            projectContributors = await fundingService.getProjectContributorList(projectAddress);
            const finalProjectContributorsLength = projectContributors.length;

            assert.equal(finalProjectBalance.toNumber(), initialProjectBalance.toNumber() + amountToContribute, "Project contract balance incorrect");
            assert.equal(finalContributionAmount.toNumber(), initialContributionAmount.toNumber() + amountToContribute, "FundingService record of this addresses contribution amount incorrect");
            assert.equal(finalProjectContributorsLength, initialProjectContributorsLength + 1, "Project contributors length incorrect");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
