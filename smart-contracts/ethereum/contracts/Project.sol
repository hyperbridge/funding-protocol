pragma solidity ^0.4.23;
import "./FundingService.sol";

contract Project {
    struct ProjectMilestone {
        string title;
        string description;
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
    address public developer;
    uint public developerId;
    uint public contributionGoal;
    ProjectTimeline timeline;
    ProjectTimeline[] timelineHistory;
    ProjectTimeline pendingTimeline;

    modifier devRestricted() {
        require(msg.sender == developer);
        _;
    }

    constructor(address _fundingService, uint _id, string _title, string _description, string _about, address _developer, uint _developerId, uint _contributionGoal) public {
        fundingService = _fundingService;
        id = _id;
        status = Statuses.Draft;
        title = _title;
        description = _description;
        about = _about;
        developer = _developer;
        developerId = _developerId;
        contributionGoal = _contributionGoal;
    }

    function addMilestone(string milestoneTitle, string milestoneDescription) public devRestricted {
        ProjectMilestone memory newMilestone = ProjectMilestone({
            title: milestoneTitle,
            description: milestoneDescription,
            isComplete: false
            });

        pendingTimeline.milestones.push(newMilestone);
    }

    function() public payable { }
}
