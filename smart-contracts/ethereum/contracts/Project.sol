pragma solidity ^0.4.23;

contract ProjectFactory {
    address[] public deployedProjects;

    function createProject(string _title, string _description, string _about) public {
        Project newProject = new Project(_title, _description, _about, msg.sender);
        deployedProjects.push(newProject);
    }

    function getDeployedProjects() public view returns (address[]) {
        return deployedProjects;
    }
}

contract Project {
    string public title;
    string public description;
    string public about;
    address public developer;
    mapping(address => bool) public contributors;
    address[] public contributorList;

    modifier restricted() {
        require(msg.sender == developer);
        _;
    }

    constructor(string _title, string _description, string _about, address _developer) public {
        title = _title;
        description = _description;
        about = _about;
        developer = _developer;
    }

    function contribute() public payable {
        // TODO prevent double contributions? log total contribution instead of bool?
        contributors[msg.sender] = true;
        contributorList.push(msg.sender);
     }

    function getContributorList() public view returns (address[]) {
        return contributorList;
    }
}
