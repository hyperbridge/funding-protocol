pragma solidity ^0.4.23;

contract Developer {
    address public owner;
    string public name;
    mapping(address => uint) public projects;
    address[] public projectList;

    modifier restricted() {
        require(msg.sender == owner);
        _;
    }

    constructor(string _name) public {
        owner = msg.sender;
        name = _name;

        // Reserve index 0
        projectList.push(0);
    }

    function addProject(address _project) public restricted {
        // TODO check if project has already been added
        // TODO verify that _project is actually a Project (...how though?)
        projects[_project] = projectList.length;
        projectList.push(_project);
    }

    function removeProject(address _project) public restricted {
        // If project has been added, then remove it
        uint index = projects[_project];
        if (index != 0) {
            delete projectList[index];
            delete projects[_project];
        }
    }

    function getProjectList() public view returns (address[]) {
        return projectList;
    }
}
