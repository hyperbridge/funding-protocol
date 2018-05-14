pragma solidity ^0.4.23;
import "./Project.sol";

contract FundingService {
    struct Developer {
        uint id;
        address owner;
        string name;
        mapping(uint => uint) projectIdIndex; // mapping of project id to index in Developer.projectIds
        uint[] projectIds; // the projects belonging to this developer
    }

    address public owner;

    mapping(uint => Developer) public developers;
    uint[] public developerIds;

    mapping(address => uint) public projectMap;
    address[] public projects; // indexed by project id

    modifier devRestricted(uint _developerId) {
        require(developers[_developerId].id == _developerId); // check that developer exists
        require(msg.sender == developers[_developerId].owner);
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
            owner: msg.sender,
            name: _name,
            projectIds: new uint[](0)
        });

        developerIds.push(newDeveloper.id);
        developers[newDeveloper.id] = newDeveloper;

        // reserve index 0 in developers projectIds
        Developer storage createdDeveloper = developers[newDeveloper.id];
        createdDeveloper.projectIds.push(0);
        createdDeveloper.projectIdIndex[newDeveloper.id] = createdDeveloper.projectIds.length;
    }

    function getDeveloper(uint _id) public view returns (address devOwner, string name, uint[] projectIds) {
        require(developers[_id].id == _id); // check that developer exists

        Developer memory dev = developers[_id];
        return (dev.owner, dev.name, dev.projectIds);
    }

    function addProject(string _title, string _description, string _about, uint _developerId) public devRestricted(_developerId) {
        uint newProjectId = projects.length;

        Project newProject = new Project(this, newProjectId, _title, _description, _about, _developerId);

        projectMap[newProject] = newProjectId;
        projects.push(newProject);

        Developer storage dev = developers[_developerId];

        dev.projectIds.push(newProjectId);
    }

    function removeProject(uint _projectId, uint _developerId) public devRestricted(_developerId) {
        Developer storage dev = developers[_developerId];

        require(dev.projectIds[dev.projectIdIndex[_projectId]] == _projectId); // check that project belongs to developer

        // TODO - What behaviour here? Refund money? Self destruct? Remove from registry/developer?
    }

    function contributeToProject(uint _projectId) public payable {
        address projectAddress = projects[_projectId];

        require(projectAddress != 0); // check that project exists

        Project project = Project(projectAddress);

        project.contribute.value(msg.value)(msg.sender);
    }
}
