const FundingService = artifacts.require("FundingService");
const Project = artifacts.require("Project");

contract('FundingService', function(accounts) {
    let fundingService;
    let fundingServiceOwner;
    let devName;
    let devAccount;
    let projectTitle;
    let projectDescription;
    let projectAbout;
    let projectDevId;
    let projectContributionGoal;

    before(async () => {
        fundingService = await FundingService.deployed();

        devName = "Hyperbridge";
        fundingServiceOwner = accounts[0];
        devAccount = accounts[1];

        await fundingService.createDeveloper(devName, { from: devAccount });

        projectTitle = "Blockhub";
        projectDescription = "This is a description of Blockhub.";
        projectAbout = "These are the various features of Blockhub.";
        projectDevId = await fundingService.developerMap.call(devAccount);
        projectContributionGoal = 1000000;

        await fundingService.createProject(projectTitle, projectDescription, projectAbout, projectDevId, projectContributionGoal, {from: devAccount});
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
           assert.equal(createdDeveloper[1], devAccount, "Incorrect address");
           assert.equal(createdDeveloper[2], devName, "Incorrect name");
       } catch (e) {
           console.log(e.message);
           assert.fail();
       }
    });

    it("should be able to create Project", async () => {
        try {
            const projectAddress = await fundingService.projects.call(1);

            // Check if project has an address
            assert.notEqual(projectAddress, 0);

            let projectId = await fundingService.projectMap.call(projectAddress);

            // Check that project has ID
            assert.equal(projectId.toNumber(), 1);

            const project = await Project.at(projectAddress);

            let createdProjectId = await project.id.call();
            let createdProjectDevId = await project.developerId.call();
            let createdProjectContributionGoal = await project.contributionGoal.call();

            assert.equal(await project.fundingService.call(), fundingService.address);
            assert.equal(createdProjectId.toNumber(), projectId.toNumber());
            assert.equal(await project.title.call(), projectTitle);
            assert.equal(await project.description.call(), projectDescription);
            assert.equal(await project.about.call(), projectAbout);
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
            const projectAddress = await fundingService.projects.call(1);
            const project = await Project.at(projectAddress);

            await project.addMilestone("Title 1", "Description 1", 30, false, { from: devAccount });
            await project.addMilestone("Title 2", "Description 2", 50, false, { from: devAccount });
            await project.addMilestone("Title 3", "Description 3", 20, false, { from: devAccount });

            await project.addTier(1000, 10000, 500, "These are the rewards.", { from: devAccount });
            await project.addTier(500, 499, 1, "More rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(1, 1, { from: devAccount });

            const projectStatus = await project.status.call();

            assert.equal(projectStatus, 1, "FundingService did not change valid project's status to Pending.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should reject project submitted for review with invalid milestones", async () => {
        try {
            await fundingService.createProject("New Title", "New Desc", "New About", projectDevId, 20000, {from: devAccount});

            const projectAddress = await fundingService.projects.call(2);
            const project = await Project.at(projectAddress);

            await project.addMilestone("Title 1", "Description 1", 30, false, { from: devAccount });
            await project.addMilestone("Title 2", "Description 2", 50, false, { from: devAccount });
            await project.addMilestone("Title 3", "Description 3", 21, false, { from: devAccount });

            await project.addTier(1000, 10000, 500, "These are the rewards.", { from: devAccount });
            await project.addTier(500, 499, 1, "More rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(1, 1, { from: devAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should reject project submitted for review with no contribution tiers", async () => {
        try {
            await fundingService.createProject("New Title", "New Desc", "New About", projectDevId, 20000, {from: devAccount});

            const projectAddress = await fundingService.projects.call(2);
            const project = await Project.at(projectAddress);

            await project.addMilestone("Title 1", "Description 1", 30, false, { from: devAccount });
            await project.addMilestone("Title 2", "Description 2", 50, false, { from: devAccount });
            await project.addMilestone("Title 3", "Description 3", 20, false, { from: devAccount });

            await fundingService.submitProjectForReview(1, 1, { from: devAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("new contributor should be able to contribute to a project", async function() {
        try {
            const amountToContribute = 1000;

            const projectId = 1;
            const projectAddress = await fundingService.projects.call(projectId);

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

            const projectId = 1;
            const projectAddress = await fundingService.projects.call(projectId);

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
            assert.equal(finalProjectContributorsLength, initialProjectContributorsLength, "Project contributors length incorrect");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
