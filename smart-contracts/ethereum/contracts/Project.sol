pragma solidity ^0.4.23;

contract Project {
    struct ProjectMilestone {
        string title;
        string description;
        string[] conditions;
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
    ProjectTimeline pendingTimeline;

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

    function proposeTimelineUpdate(string[] titles, string[] descriptions, string[][] conditions, uint[] percentages, bool[] isCompletes) public {
        require(titles.length == descriptions.length);
        require(descriptions.length == conditions.length);
        require(conditions.length == percentages.length);
        require(percentages.length == isCompletes.length);

        ProjectTimeline proposedTimeline;

        // new timeline must begin with already completed milestones from previous timeline
        for (uint i = 0; i < timeline.milestones.length; i++) {
            if (!timeline.milestones[i].isComplete) {
                break;
            } else {
                proposedTimeline.push(timeline.milestones[i]);
            }
        }

        // add newly proposed milestones
        for (uint i = 0; i < titles.length; i++) {
            ProjectMilestone newMilestone = ProjectMilestone({
                title: titles[i],
                description: descriptions[i],
                conditions: conditions[i],
                percentage: percentages[i],
                isComplete: isCompletes[i]
            });

            proposedTimeline.push(newMilestone);
        }

        pendingTimeline = proposedTimeline;
    }

    function() public payable { }
}
