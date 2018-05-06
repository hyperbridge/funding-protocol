pragma solidity ^0.4.23;

contract Developer {
    address public owner;
    string public name;
    mapping(address => bool) public projects;
    address[] public projectList;

    modifier restricted() {
        require(msg.sender == owner);
        _;
    }

    constructor(string devName) public {
        owner = msg.sender;
        name = devName;
    }

    function addProject(address projectAddress) public restricted {
        // If project has not already been added, then add it
        if (!projects[projectAddress]) {
            projects[projectAddress] = true;
            projectList.push(projectAddress);
        }
    }

    function removeProject(address projectAddress) public restricted {
        // If project has been added, then remove it
        if (projects[projectAddress]) {
            delete projects[projectAddress];
            removeProjectFromProjectList(projectAddress);
        }
    }

    function getProjectList() public view returns (address[]) {
        return projectList;
    }

    function removeProjectFromProjectList(address projectAddress) private {
        for (uint i = 0; i < projectList.length; i++) {
            if (projectList[i] == projectAddress) {
                delete projectList[i];
                for (uint j = i; j < projectList.length - 1; j++) {
                    projectList[j] = projectList[j + 1];
                }
                projectList.length--;
                return;
            }
        }
    }
}
