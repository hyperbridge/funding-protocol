const ProjectFactory = artifacts.require("ProjectFactory");
const Project = artifacts.require("Project");

contract('Project', function(accounts) {
    it("should deploy a ProjectFactory contract", async () => {
        try {
            let factory = await ProjectFactory.deployed();

            assert.ok(factory.address);
        } catch (e) {
            console.log(e);
            assert.fail();
        }
    });

    it("should be able to create Project with factory", async () => {
        try {
            let factory = await ProjectFactory.deployed();

            let title = "Project Name";
            let description = "This is a project.";
            let about = "About this project";

            await factory.createProject(title, description, about, {from: accounts[0]});

            let projectAddress = await factory.deployedProjects.call(0);
            let project = await Project.at(projectAddress);

            // Check if project has an address
            assert.ok(project.address);

            // Check if project is owned by the account that called ProjectFactory.createProject()
            let developer = await project.developer.call();
            assert.equal(developer, accounts[0], "Created project not owned by correct developer.");

            // Check that ProjectFactory increased the total number of deployed Projects
            let deployedProjects = await factory.getDeployedProjects.call();
            assert.equal(deployedProjects.length, 1, "Incorrect number of deployed contracts.");
        } catch (e) {
            console.log(e);
            assert.fail();
        }
    });

    it("should be able to contribute to a project", async function() {
        try {
            const amountToContribute = 1000000;

            let factory = await ProjectFactory.deployed();

            let title = "Project Name";
            let description = "This is a project.";
            let about = "About this project";

            await factory.createProject(title, description, about, { from: accounts[0] });

            let projectAddress = await factory.deployedProjects.call(0);
            let project = await Project.at(projectAddress);

            let projectInitialBalance = await web3.eth.getBalance(project.address);

            let contributorList = await project.getContributorList.call();
            let initialContributerListLength = contributorList.length;

            await project.contribute({ from: accounts[1], value: amountToContribute });

            let newProjectBalance = await web3.eth.getBalance(project.address);

            let newContributorList = await project.getContributorList.call();
            let newContributorListLength = newContributorList.length;

            assert.equal(newProjectBalance.toNumber(), projectInitialBalance.toNumber() + amountToContribute, "Project contract balance incorrect.");
            assert.equal(newContributorListLength, initialContributerListLength + 1, "Contributor list length not correct.");
            assert.ok(project.contributors.call(accounts[1]));
        } catch (e) {
            console.log(e);
            assert.fail();
        }
    });
});
