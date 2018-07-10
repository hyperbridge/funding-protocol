pragma solidity ^0.4.23;

import "./Project.sol";
import "./openzeppelin/Ownable.sol";

contract FundingService is Ownable {

    struct Developer {
        uint id;
        uint reputation;
        address addr;
        string name;
        mapping(uint => bool) ownsProject; // project id => owned by this dev
        uint[] projectIds; // the projects belonging to this developer
    }

    struct Contributor {
        address addr;
        mapping(uint => bool) contributesToProject;
        uint[] activeProjects;
    }

    address public projectRegistry;

    mapping(address => uint) public developerMap; // address => id
    Developer[] public developers; // indexed by developer id

    mapping(address => Contributor) public contributors;

    mapping(uint => mapping(address => uint)) public projectContributionAmount; // project id => (contributor address => contribution amount)
    mapping(uint => address[]) projectContributorList; // project address => Contributors[]

    modifier devRestricted(uint _developerId) {
        require(developers[_developerId].id == _developerId, "Developer does not exist."); // check that developer exists
        require(msg.sender == developers[_developerId].addr, "Address does not match specified developer.");
        _;
    }

    // modifier validProjectOnly(uint _developerId) {
    //     // Caller must be a project
    //     uint projectId = projectMap[msg.sender];
    //     require(projectId != 0, "Caller must be a project.");

    //     // Caller must be a project created by the specified developer
    //     Developer storage developer = developers[_developerId];
    //     require(developer.projectIdIndex[projectId] != 0, "Caller must be a project created by the specified developer.");

    //     _;
    // }

    event ProjectCreated(uint projectId);

    constructor() public {
        // reserve 0
        developers.length++;
    }

    function () public payable {
        revert();
    }

    function registerProjectRegistry(address _projectReg) public onlyOwner {
        projectRegistry = _projectReg;
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

    function updateDeveloperReputation(uint _developerId, uint _val) public { //validProjectOnly(_developerId) {
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
        Project projectReg = Project(projectRegistry);

        uint newProjectId = projectReg.createProject(_title, _description, _about,  _contributionGoal, msg.sender,  _developerId);

        Developer storage dev = developers[_developerId];

        dev.ownsProject[newProjectId] = true;
        dev.projectIds.push(newProjectId);

        emit ProjectCreated(newProjectId);
    }

    function contributeToProject(uint _projectId) public payable {
        (bool isActive, uint status, string memory title, string memory description, string memory about, uint contributionGoal, address developer, uint developerId) = Project(projectRegistry).getProject(_projectId);

        require(isActive, "Project does not exist."); // check that project exists

        // if contributor doesn't exist, create it
        if (contributors[msg.sender].addr == 0) {
            Contributor memory newContributor = Contributor({
                addr: msg.sender,
                activeProjects: new uint[](0)
                });

            // add contributor to global contributors mapping
            contributors[msg.sender] = newContributor;
        }

        Contributor storage contributor = contributors[msg.sender];

        // if project is not in contributor's project list, add it
        if (!contributor.contributesToProject[_projectId]) {
            contributor.contributesToProject[_projectId] = true;
            contributor.activeProjects.push(_projectId);
        }

        // add to projectContributorList, if not already present
        if (projectContributionAmount[_projectId][msg.sender] == 0) {
            projectContributorList[_projectId].push(msg.sender);
        }

        // add contribution amount to project
        uint currentProjectContributionAmount = projectContributionAmount[_projectId][msg.sender];
        projectContributionAmount[_projectId][msg.sender] = currentProjectContributionAmount + msg.value;

        // TODO - money to project
    }

    function getProjectContributorList(uint _projectId) public view returns (address[]) {
        return projectContributorList[_projectId];
    }
}
