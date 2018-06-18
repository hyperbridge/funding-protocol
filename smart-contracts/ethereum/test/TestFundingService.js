const FundingService = artifacts.require("FundingService");
const Project = artifacts.require("Project");
const ProjectFactory = artifacts.require("ProjectFactory");

contract('FundingService', function(accounts) {
    let projectFactory;
    let fundingService;
    let fundingServiceOwner;
    let devAccount;
    let project;
    let projectAddress;
    let projectId;
    let projectDevId;
    const devName = "Hyperbridge";
    const projectTitle = "Blockhub";
    const projectDescription = "This is a description of Blockhub.";
    const projectAbout = "These are the various features of Blockhub.";
    const projectContributionGoal = 1000000;

    before(async () => {
        projectFactory = await ProjectFactory.deployed();

        fundingService = await FundingService.deployed();

        fundingServiceOwner = accounts[0];
        devAccount = accounts[1];

        await fundingService.registerProjectFactory(projectFactory.address);

        await fundingService.createDeveloper(devName, { from: devAccount });

        projectDevId = await fundingService.developerMap.call(devAccount);
    });

    beforeEach(async () => {
        let watcher = fundingService.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectAddress = result.args.projectAddress;
                projectId = result.args.projectId;
            }
        });

        await fundingService.createProject(projectTitle, projectDescription, projectAbout, projectDevId, projectContributionGoal, {from: devAccount});

        watcher.stopWatching();

        project = await Project.at(projectAddress);
    });

    it("should deploy a ProjectFactory contract", async () => {
        try {
            assert.ok(projectFactory.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
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
            // Check if project has an address
            assert.notEqual(projectAddress, 0);

            assert.notEqual(projectId, 0);

            const createdProjectFundingService = await project.fundingService.call();
            const createdProjectId = await project.id.call();
            const createdProjectStatus = await project.status.call();
            const createdProjectTitle = await project.title.call();
            const createdProjectDescription = await project.description.call();
            const createdProjectAbout = await project.about.call();
            const createdProjectDeveloper = await project.developer.call();
            const createdProjectDevId = await project.developerId.call();
            const createdProjectContributionGoal = await project.contributionGoal.call();

            assert.equal(createdProjectFundingService, fundingService.address);
            assert.equal(createdProjectId.toNumber(), projectId);
            assert.equal(createdProjectStatus, 0);
            assert.equal(createdProjectTitle, projectTitle);
            assert.equal(createdProjectDescription, projectDescription);
            assert.equal(createdProjectAbout, projectAbout);
            assert.equal(createdProjectDeveloper, devAccount);
            assert.equal(createdProjectDevId.toNumber(), projectDevId);
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

    it("should submit project for review", async () => {
        try {
            await project.addMilestone("Title 1", "Description 1", 30, false, { from: devAccount });
            await project.addMilestone("Title 2", "Description 2", 50, false, { from: devAccount });
            await project.addMilestone("Title 3", "Description 3", 20, false, { from: devAccount });

            await project.addTier(1000, 10000, 500, "These are the rewards.", { from: devAccount });
            await project.addTier(500, 499, 1, "More rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            const projectStatus = await project.status.call();

            assert.equal(projectStatus, 1, "FundingService did not change valid project's status to Pending.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

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
