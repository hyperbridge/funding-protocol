pragma solidity ^0.4.23;

contract Project {
    address public fundingService;
    uint public id;
    string public title;
    string public description;
    string public about;
    uint public developerId;
    uint public contributionGoal;

    constructor(address _fundingService, uint _id, string _title, string _description, string _about, uint _developerId, uint _contributionGoal) public {
        fundingService = _fundingService;
        id = _id;
        title = _title;
        description = _description;
        about = _about;
        developerId = _developerId;
        contributionGoal = _contributionGoal;
    }

    function() public payable { }
}
