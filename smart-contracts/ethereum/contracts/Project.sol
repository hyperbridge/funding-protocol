pragma solidity ^0.4.23;

contract ProjectFactory {
    address[] public deployedProjects;

    function createProject(string title, string description, string about) public {
        address newProject = new Project(title, description, about, msg.sender);
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

    constructor(string projectTitle, string projectDescription, string projectAbout, address projectDeveloper) public {
        title = projectTitle;
        description = projectDescription;
        about = projectAbout;
        developer = projectDeveloper;
    }

    function contribute() public payable {
        contributors[msg.sender] = true;
        contributorList.push(msg.sender);
     }

    function getContributorList() public view returns (address[]) {
        return contributorList;
    }
}
