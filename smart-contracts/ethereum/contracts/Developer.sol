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

    constructor(string _name) public {
        owner = msg.sender;
        name = _name;
    }

    function addProject(address _project) public restricted {
        // If project has not already been added, then add it
        if (!projects[_project]) {
            projects[_project] = true;
            projectList.push(_project);
        }
    }

    function removeProject(address _project) public restricted {
        // If project has been added, then remove it
        if (projects[_project]) {
            delete projects[_project];
            removeProjectFromProjectList(_project);
        }
    }

    function getProjectList() public view returns (address[]) {
        return projectList;
    }

    function removeProjectFromProjectList(address _project) private {
        for (uint i = 0; i < projectList.length; i++) {
            if (projectList[i] == _project) {
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
