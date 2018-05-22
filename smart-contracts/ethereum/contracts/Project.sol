pragma solidity ^0.4.23;

contract Project {
    struct ProjectMilestone {
        string title;
        string description;
        string[] conditions;
        uint percentage; // TODO - Figure out how to represent this
        bool isComplete;
    }

    struct ProjectTimeline {
        ProjectMilestone[] milestones;
    }

    enum Statuses {Draft, Pending, Published, Removed, Rejected}

    address public fundingService;
    uint public id;
    Statuses public status;
    string public title;
    string public description;
    string public about;
    uint public developerId;
    uint public contributionGoal;
    ProjectTimeline timeline;
    ProjectTimeline[] timelineHistory;

    constructor(address _fundingService, uint _id, string _title, string _description, string _about, uint _developerId, uint _contributionGoal) public {
        fundingService = _fundingService;
        id = _id;
        status = Statuses.Draft;
        title = _title;
        description = _description;
        about = _about;
        developerId = _developerId;
        contributionGoal = _contributionGoal;
    }

    function() public payable { }
}
