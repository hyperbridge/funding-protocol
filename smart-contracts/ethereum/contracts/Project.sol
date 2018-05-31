pragma solidity ^0.4.23;
import "./FundingService.sol";

contract Project {
    struct ProjectMilestone {
        string title;
        string description;
        uint percentage;
        bool isComplete;
    }

    struct ProjectTimeline {
        ProjectMilestone[] milestones;
    }

    struct ProjectTier {
        uint contributorLimit;
        uint minContribution;
        uint maxContribution;
        string rewards;
    }

    enum Statuses {Draft, Pending, Published, Removed, Rejected}

    enum Terms {NoRefunds, NoTimeline}

    address public fundingService;
    uint public id;
    Statuses public status;
    string public title;
    string public description;
    string public about;
    address public developer;
    uint public developerId;
    uint public contributionGoal;
    ProjectTier[] contributionTiers;
    ProjectTier[] pendingContributionTiers;
    Terms[] terms;
    ProjectTimeline timeline;
    ProjectTimeline[] timelineHistory;
    ProjectTimeline pendingTimeline;

    modifier devRestricted() {
        require(msg.sender == developer);
        _;
    }

    modifier fundingServiceRestricted() {
        require(msg.sender == fundingService);
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

    function addMilestone(string _milestoneTitle, string _milestoneDescription, uint _percentage) public devRestricted {
        require(_percentage <= 100);

        ProjectMilestone memory newMilestone = ProjectMilestone({
            title: _milestoneTitle,
            description: _milestoneDescription,
            percentage: _percentage,
            isComplete: false
            });

        pendingTimeline.milestones.push(newMilestone);
    }

    function editMilestone(
        uint _index,
        string _milestoneTitle,
        string _milestoneDescription,
        uint _milestonePercentage)
    public devRestricted {
        ProjectMilestone storage milestone = pendingTimeline.milestones[_index];

        milestone.title = _milestoneTitle;
        milestone.description = _milestoneDescription;
        milestone.percentage = _milestonePercentage;
    }

    function getTimelineMilestone(uint _index) public view
    returns (
        string milestoneTitle,
        string milestoneDescription,
        uint milestonePercentage,
        bool milestoneIsComplete
    ) {

        ProjectMilestone memory milestone = timeline.milestones[_index];

        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function getPendingTimelineMilestoneLength() public view returns (uint) {
        return pendingTimeline.milestones.length;
    }

    function getTimelineMilestoneLength() public view returns (uint) {
        return timeline.milestones.length;
    }

    function getTimelineHistoryLength() public view returns (uint) {
        return timelineHistory.length;
    }

    function getTimelineHistory() public view returns (uint[]) {
        uint[] memory ret = new uint[](timelineHistory.length);

        for (uint i = 0; i < timelineHistory.length; i++) {
            ret[i] = timelineHistory[i].milestones.length;
        }

        return ret;
    }

    function finalizeTimeline() public devRestricted {
        if (timeline.milestones.length != 0) {
            timelineHistory.push(timeline);
        }

        timeline = pendingTimeline;

        delete(pendingTimeline.milestones);
    }

    function setStatus(uint _status) public fundingServiceRestricted {
        status = Statuses(_status);
    }

    function setTerms(uint[] _terms) public devRestricted {
        // clear existing terms
        delete(terms);

        // add terms
        for (uint i = 0; i < terms.length; i++) {
            terms.push(Terms(_terms[i]));
        }
    }

    function getTerms() public view returns (Terms[]) {
        return terms;
    }

    function addTier(uint _contributorLimit, uint _maxContribution, uint _minContribution, string _rewards) public devRestricted {
        ProjectTier memory newTier = ProjectTier({
            contributorLimit: _contributorLimit,
            maxContribution: _maxContribution,
            minContribution: _minContribution,
            rewards: _rewards
            });

        pendingContributionTiers.push(newTier);
    }

    function editTier(
        uint _index,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards)
    public devRestricted {
        ProjectTier storage tier = pendingContributionTiers[_index];

        tier.contributorLimit = _contributorLimit;
        tier.maxContribution = _maxContribution;
        tier.minContribution = _minContribution;
        tier.rewards = _rewards;
    }

    function getTiersLength() public view returns (uint) {
        return contributionTiers.length;
    }

    function getContributionTier(uint _index) public view
    returns (
        uint tierContributorLimit,
        uint tierMaxContribution,
        uint tierMinContribution,
        string tierRewards
    ) {
        ProjectTier memory tier = contributionTiers[_index];

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
    }

    function finalizeTiers() public devRestricted {
        contributionTiers = pendingContributionTiers;

        delete(pendingContributionTiers);
    }


    function() public payable { }
}
