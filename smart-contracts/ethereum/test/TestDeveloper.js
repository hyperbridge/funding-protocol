const Developer = artifacts.require("Developer");
const ProjectFactory = artifacts.require("ProjectFactory");
const Project = artifacts.require("Project");

contract('Developer', function(accounts) {
    let developer;
    let factory;
    let project;

    beforeEach(async () => {
        developer = await Developer.new("Hyperbridge");

    });

    it("should deploy a developer contract with appropriate owner and name", async () => {
        try {
            let owner = await developer.owner.call({from: accounts[0]});
            let name = await developer.name.call({from: accounts[0]});

            assert.ok(developer.address);
            const expectedOwner = accounts[0];
            const expectedName = "Hyperbridge";
            assert.equal(owner, expectedOwner, "Owner of contract was not the creator.");
            assert.equal(name, expectedName, "Incorrect contract name.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to add a Project", async () => {
        try {
            factory = await ProjectFactory.deployed();

            let title = "Project Name";
            let description = "This is a project.";
            let about = "About this project";

            await factory.createProject(title, description, about, {from: accounts[0]});

            let projectAddress = await factory.deployedProjects.call(0, {from: accounts[0]});
            project = await Project.at(projectAddress);

            await developer.addProject(project.address, {from: accounts[0]});

            let projectIndex = await developer.projects.call(project.address, {from: accounts[0]});
            assert.ok(projectIndex.toNumber());

            let projectList = await developer.getProjectList.call({from: accounts[0]});
            assert.equal(projectList.length, 2, "projectList incorrect length.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to remove a Project", async () => {
        try {
            factory = await ProjectFactory.deployed();

            let title = "Project Name";
            let description = "This is a project.";
            let about = "About this project";

            await factory.createProject(title, description, about, {from: accounts[0]});

            let projectAddress = await factory.deployedProjects.call(0, {from: accounts[0]});
            project = await Project.at(projectAddress);

            await developer.addProject(project.address, {from: accounts[0]});

            let projectIndex = await developer.projects.call(project.address, {from: accounts[0]});
            assert.ok(projectIndex.toNumber());

            let projectList = await developer.getProjectList.call({from: accounts[0]});
            assert.equal(projectList.length, 2, "projectList incorrect length.");

            await developer.removeProject(project.address, {from: accounts[0]});

            projectIndex = await developer.projects.call(project.address, {from: accounts[0]});
            assert.ok(!projectIndex.toNumber());

            assert.equal(projectList[projectIndex], 0, "Project not deleted from projectList.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should reject non-owner from adding Project", async () => {
        try {
            factory = await ProjectFactory.deployed();

            let title = "Project Name";
            let description = "This is a project.";
            let about = "About this project";

            await factory.createProject(title, description, about, {from: accounts[0]});

            let projectAddress = await factory.deployedProjects.call(0, {from: accounts[0]});
            project = await Project.at(projectAddress);

            await developer.addProject(project.address, {from: accounts[1]});
        } catch (e) {
            console.log(e.message);
            let projectIndex = await developer.projects.call(project.address, {from: accounts[0]});
            assert.ok(!projectIndex.toNumber());

            let projectList = await developer.getProjectList.call({from: accounts[0]});
            assert.equal(projectList.length, 1, "projectList incorrect length.");
        }
    });

    it("should reject non-owner from removing a Project", async () => {
        try {
            factory = await ProjectFactory.deployed();

            let title = "Project Name";
            let description = "This is a project.";
            let about = "About this project";

            await factory.createProject(title, description, about, {from: accounts[0]});

            let projectAddress = await factory.deployedProjects.call(0, {from: accounts[0]});
            project = await Project.at(projectAddress);

            await developer.addProject(project.address, {from: accounts[0]});

            let projectIndex = await developer.projects.call(project.address, {from: accounts[0]});
            assert.ok(projectIndex.toNumber());

            let projectList = await developer.getProjectList.call({from: accounts[0]});
            assert.equal(projectList.length, 2, "projectList incorrect length.");

            await developer.removeProject(project.address, {from: accounts[1]});
        } catch (e) {
            console.log(e.message);
            let projectIndex = await developer.projects.call(project.address, {from: accounts[0]});
            assert.ok(projectIndex.toNumber());

            let projectList = await developer.getProjectList.call({from: accounts[0]});
            assert.equal(projectList.length, 2, "projectList incorrect length.");
        }
    });
});
