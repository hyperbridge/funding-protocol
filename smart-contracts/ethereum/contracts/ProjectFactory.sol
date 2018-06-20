pragma solidity ^0.4.23 ;

import "./Project.sol";

contract ProjectFactory {
    function createProject(uint _id, string _title, string _description, string _about, address _developer, uint _developerId, uint _contributionGoal) public returns (address) {
        Project newProject = new Project(msg.sender, _id, _title, _description, _about, _developer, _developerId, _contributionGoal);
        return address(newProject);
    }

    function () public payable {
        revert();
    }
}
