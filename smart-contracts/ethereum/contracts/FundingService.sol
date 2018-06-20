pragma solidity ^0.4.23;

import "./Project.sol";
import "./ProjectFactory.sol";
import "./openzeppelin/Ownable.sol";

contract FundingService is Ownable {

    struct Developer {
        uint id;
        uint reputation;
        address addr;
        string name;
        mapping(uint => uint) projectIdIndex; // mapping of project id to index in Developer.projectIds
        uint[] projectIds; // the projects belonging to this developer
    }

    struct Contributor {
        address addr;
        mapping(address => bool) projectExists;
        address[] activeProjects;
    }

    address public projectFactory;

    mapping(address => uint) public developerMap; // address => id
    Developer[] public developers; // indexed by developer id

    mapping(address => Contributor) public contributors;

    mapping(address => mapping(address => uint)) public projectContributionAmount; // project address => (contributor address => contribution amount)
    mapping(address => address[]) projectContributorList; // project address => Contributors[]

    mapping(address => uint) public projectMap; // address => id
    address[] public projects; // indexed by project id

    modifier devRestricted(uint _developerId) {
        require(developers[_developerId].id == _developerId, "Developer does not exist."); // check that developer exists
        require(msg.sender == developers[_developerId].addr, "Address does not match specified developer.");
        _;
    }

    modifier validProjectOnly(uint _developerId) {
        // Caller must be a project
        uint projectId = projectMap[msg.sender];
        require(projectId != 0, "Caller must be a project.");

        // Caller must be a project created by the specified developer
        Developer storage developer = developers[_developerId];
        require(developer.projectIdIndex[projectId] != 0, "Caller must be a project created by the specified developer.");

        _;
    }

    event ProjectCreated(address projectAddress, uint projectId);

    constructor() public {
        // reserve 0
        developers.length++;
        projects.push(0);
    }

    function () public payable {
        revert();
    }

    function registerProjectFactory(address _factoryAddr) public onlyOwner {
        projectFactory = _factoryAddr;
    }

    function createDeveloper(string _name) public {
        require(developerMap[msg.sender] == 0, "This account is already a developer."); // require that this account is not already a developer

        Developer memory newDeveloper = Developer({
            id: developers.length,
            reputation: 0,
            addr: msg.sender,
            name: _name,
            projectIds: new uint[](0)
            });

        developers.push(newDeveloper);
        developerMap[msg.sender] = newDeveloper.id;

        // Reserve 0 in developer's projectIds
        Developer storage createdDeveloper = developers[newDeveloper.id];
        createdDeveloper.projectIds.push(0);
    }

    function getDeveloper(uint _id) public view returns (uint reputation, address addr, string name, uint[] projectIds) {
        require(developers[_id].id == _id, "Developer does not exist."); // check that developer exists

        Developer memory dev = developers[_id];
        return (dev.reputation, dev.addr, dev.name, dev.projectIds);
    }

    function updateDeveloperReputation(uint _developerId, uint _val) public validProjectOnly(_developerId) {
        Developer storage developer = developers[_developerId];

        uint currentRep = developer.reputation;

        developer.reputation = currentRep + _val;
    }

    function getDevelopers() public view returns (address[]) {
        address[] memory addresses = new address[](developers.length - 1);

        for (uint i = 1; i < developers.length; i++) {
            Developer memory developer = developers[i];
            addresses[i - 1] = (developer.addr);
        }

        return addresses;
    }

    function createProject(string _title, string _description, string _about, uint _developerId, uint _contributionGoal) public devRestricted(_developerId) {
        require(projectFactory != address(0), "No project factory registered.");

        ProjectFactory factory = ProjectFactory(projectFactory);

        uint newProjectId = projects.length;

        address newProject = factory.createProject(newProjectId, _title, _description, _about,  msg.sender,  _developerId, _contributionGoal);

        projectMap[newProject] = newProjectId;
        projects.push(newProject);

        Developer storage dev = developers[_developerId];

        dev.projectIdIndex[newProjectId] = dev.projectIds.length;
        dev.projectIds.push(newProjectId);

        emit ProjectCreated(newProject, newProjectId);
    }

    function submitProjectForReview(uint _projectId, uint _developerId) public devRestricted(_developerId) {
        address projectAddress = projects[_projectId];

        // check that project exists
        require(projectAddress != address(0), "Project does not exist.");

        Project project = Project(projectAddress);

        verifyProjectMilestones(project);

        verifyProjectTiers(project);

        // Set project status to "Pending" and change timeline to active
        project.initializeTimeline();
    }

    function verifyProjectMilestones(address _project) private view {
        Project project = Project(_project);

        // If project has a timeline, verify:
        // - Milestones are present
        // - Milestone percentages add up to 100
        if (!project.noTimeline()) {
            uint timelineLength = project.getTimelineMilestoneLength();

            require(timelineLength > 0, "Project has no milestones.");

            uint percentageAcc = 0;
            for (uint j = 0; j < timelineLength; j++) {
                // todo - is there a way to ignore multiple returns?
                string memory title;
                string memory description;
                uint percentage;
                bool isComplete;
                (title, description, percentage, isComplete) = project.getMilestone(j, false);
                percentageAcc = percentageAcc + percentage;
            }
            require(percentageAcc == 100, "Milestone percentages must add to 100.");
        }
    }

    function verifyProjectTiers(address _project) private view {
        Project project = Project(_project);

        // Verify that project has contribution tiers
        uint tiersLength = project.getTiersLength();
        require(tiersLength > 0, "Project has no contribution tiers.");
    }

    function getProjects() public view returns (address[]) {
        address[] memory addresses = new address[](projects.length - 1);

        for (uint i = 1; i < projects.length; i++) {
            addresses[i - 1] = projects[i];
        }

        return addresses;
    }

    function contributeToProject(uint _projectId) public payable {
        address projectAddress = projects[_projectId];

        require(projectAddress != 0, "Project does not exist."); // check that project exists

        // if contributor doesn't exist, create it
        if (contributors[msg.sender].addr == 0) {
            Contributor memory newContributor = Contributor({
                addr: msg.sender,
                activeProjects: new address[](0)
                });

            // add contributor to global contributors mapping
            contributors[msg.sender] = newContributor;
        }

        Contributor storage contributor = contributors[msg.sender];

        // if project is not in contributor's project list, add it
        if (!contributor.projectExists[projectAddress]) {
            contributor.projectExists[projectAddress] = true;
            contributor.activeProjects.push(projectAddress);
        }

        // add to projectContributorList, if not already present
        if (projectContributionAmount[projectAddress][msg.sender] == 0) {
            projectContributorList[projectAddress].push(msg.sender);
        }

        // add contribution amount to project
        uint currentProjectContributionAmount = projectContributionAmount[projectAddress][msg.sender];
        projectContributionAmount[projectAddress][msg.sender] = currentProjectContributionAmount + msg.value;

        // transfer money to project
        projectAddress.transfer(msg.value);
    }

    function getProjectContributorList(address _projectAddress) public view returns (address[]) {
        return projectContributorList[_projectAddress];
    }
}
