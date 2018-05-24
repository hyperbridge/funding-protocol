pragma solidity ^0.4.23;
import "./Project.sol";

contract FundingService {
    struct Developer {
        uint id;
        address addr;
        string name;
        mapping(uint => uint) projectIdIndex; // mapping of project id to index in Developer.projectIds
        uint[] projectIds; // the projects belonging to this developer
    }

    struct Contributor {
        address addr;
        mapping(address => bool) projectExists;
        address[] activeProjects;
        address[] oldProjects;
    }

    address public owner;

    mapping(address => uint) public developerMap; // address => id
    mapping(uint => Developer) public developers; // id => Developer
    uint[] public developerIds;

    mapping(address => Contributor) public contributors;

    mapping(address => mapping(address => uint)) public projectContributionAmount; // project address => (contributor address => contribution amount)
    mapping(address => address[]) public projectContributorList; // project address => Contributors[]

    mapping(address => uint) public projectMap; // address => id
    address[] public projects; // indexed by project id

    modifier devRestricted(uint _developerId) {
        require(developers[_developerId].id == _developerId); // check that developer exists
        require(msg.sender == developers[_developerId].addr);
        _;
    }

    constructor() public {
        owner = msg.sender;

        // reserve 0
        developerIds.push(0);
        projects.push(0);
    }

    function createDeveloper(string _name) public {
        Developer memory newDeveloper = Developer({
            id: developerIds.length,
            addr: msg.sender,
            name: _name,
            projectIds: new uint[](0)
            });

        developerIds.push(newDeveloper.id);
        developers[newDeveloper.id] = newDeveloper;
        developerMap[msg.sender] = newDeveloper.id;

        // reserve index 0 in developers projectIds
        Developer storage createdDeveloper = developers[newDeveloper.id];
        createdDeveloper.projectIds.push(0);
        createdDeveloper.projectIdIndex[newDeveloper.id] = createdDeveloper.projectIds.length;
    }

    function getDeveloper(uint _id) public view returns (address addr, string name, uint[] projectIds) {
        require(developers[_id].id == _id); // check that developer exists

        Developer memory dev = developers[_id];
        return (dev.addr, dev.name, dev.projectIds);
    }

    function createProject(string _title, string _description, string _about, uint _developerId, uint _contributionGoal) public devRestricted(_developerId) {
        uint newProjectId = projects.length;

        Project newProject = new Project(this, newProjectId, _title, _description, _about,  msg.sender,  _developerId, _contributionGoal);
        projectMap[newProject] = newProjectId;
        projects.push(newProject);

        Developer storage dev = developers[_developerId];

        dev.projectIds.push(newProjectId);
    }

    function submitProjectForReview(uint _projectId, uint _developerId) public devRestricted(_developerId) {
        address projectAddress = projects[_projectId];

        require(projectAddress != 0); // check that project exists

        Project project = Project(projectAddress);

        // verify project
        require(project.getTimelineMilestoneLength() > 0);

        project.setStatusToPending();
    }

    function contributeToProject(uint _projectId) public payable {
        address projectAddress = projects[_projectId];

        require(projectAddress != 0); // check that project exists

        // transfer money to project
        projectAddress.transfer(msg.value);

        // if contributor doesn't exist, create it
        if (contributors[msg.sender].addr == 0) {
            Contributor memory newContributor = Contributor({
                addr: msg.sender,
                activeProjects: new address[](0),
                oldProjects: new address[](0)
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

        // add contribution amount to project
        projectContributionAmount[projectAddress][msg.sender] += msg.value;

        // add to projectContributorList
        projectContributorList[projectAddress].push(msg.sender);
    }
}
