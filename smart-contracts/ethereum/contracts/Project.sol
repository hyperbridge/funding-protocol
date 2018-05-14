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

    address public fundingService;
    uint public id;
    string public title;
    string public description;
    string public about;
    uint public developerId;
    uint public contributionGoal;

    mapping(address => uint) public contributions;
    mapping(address => uint) public contributorMap; // mapping (address of contributor => index in contributors)
    address[] public contributors;

    ProjectTimeline timeline;
    ProjectTimeline[] timelineHistory;

    constructor(address _fundingService, uint _id, string _title, string _description, string _about, uint _developerId) public {
        fundingService = _fundingService;
        id = _id;
        title = _title;
        description = _description;
        about = _about;
        developerId = _developerId;

        // reserve 0
        contributors.push(0);
    }

    function contribute(address _contributor) public payable {
        contributions[_contributor] += msg.value;

        if (contributorMap[_contributor] == 0) {
            contributorMap[_contributor] = contributors.length;
            contributors.push(_contributor);
        }
    }

    function getContributors() public view returns (address[]) {
        return contributors;
    }

    function addMilestone(string _title, string _description, string[] _conditions, uint _percentage) public {
        ProjectMilestone memory newMilestone = ProjectMilestone({
            title: _title,
            description: _description,
            conditions: _conditions,
            percentage: _percentage,
            isComplete: false
        });

        timeline.milestones.push(newMilestone);
    }

    function finalizeTimeline(ProjectTimeline _tentativeTimeline) public {
        // check that milestones make sense (percentages add up, etc.)
    }
}
