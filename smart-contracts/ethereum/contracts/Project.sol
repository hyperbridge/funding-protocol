pragma solidity ^0.4.23;
import "./FundingService.sol";
import "./Bounty.sol"

contract Project {
    struct ProjectMilestone {
        string title;
        string description;
        uint percentage;
        bool isComplete;
    }

    struct ProjectTier {
        uint contributorLimit;
        uint minContribution;
        uint maxContribution;
        string rewards;
    }

    enum Status {Draft, Pending, Published, Removed, Rejected}

    address public fundingService;
    uint public id;
    Status public status;
    string public title;
    string public description;
    string public about;
    address public developer;
    uint public developerId;
    uint public contributionGoal;
    ProjectTier[] contributionTiers;
    ProjectTier[] pendingContributionTiers;
    bool public noRefunds;
    bool public noTimeline;
    ProjectMilestone[] timeline;
    ProjectMilestone[][] timelineHistory;
    ProjectMilestone[] pendingTimeline;

    Bounty[] bounties;

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
        status = Status.Draft;
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

        pendingTimeline.push(newMilestone);
    }

    function editMilestone(
        uint _index,
        string _milestoneTitle,
        string _milestoneDescription,
        uint _milestonePercentage)
    public devRestricted {
        ProjectMilestone storage milestone = pendingTimeline[_index];

        milestone.title = _milestoneTitle;
        milestone.description = _milestoneDescription;
        milestone.percentage = _milestonePercentage;
    }

    function getPendingTimelineMilestone(uint _index) public view
    returns (
        string milestoneTitle,
        string milestoneDescription,
        uint milestonePercentage,
        bool milestoneIsComplete
    ) {

        ProjectMilestone memory milestone = pendingTimeline[_index];

        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function getTimelineMilestone(uint _index) public view
    returns (
        string milestoneTitle,
        string milestoneDescription,
        uint milestonePercentage,
        bool milestoneIsComplete
    ) {

        ProjectMilestone memory milestone = timeline[_index];

        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function getPendingTimelineMilestoneLength() public view returns (uint) {
        return pendingTimeline.length;
    }

    function getTimelineMilestoneLength() public view returns (uint) {
        return timeline.length;
    }

    function getTimelineHistoryLength() public view returns (uint) {
        return timelineHistory.length;
    }

    function finalizeTimeline() public devRestricted {
        if (timeline.length != 0) {
            timelineHistory.push(timeline);
        }

        timeline = pendingTimeline;

        delete(pendingTimeline);
    }

    function setStatus(Status _status) public fundingServiceRestricted {
        status = _status;
    }

    function setNoRefunds(bool val) public devRestricted {
        noRefunds = val;
    }

    function setNoTimeline(bool val) public devRestricted {
        noTimeline = val;
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

    function getPendingTiersLength() public view returns (uint) {
        return pendingContributionTiers.length;
    }

    function getTiersLength() public view returns (uint) {
        return contributionTiers.length;
    }

    function getPendingContributionTier(uint _index) public view
    returns (
        uint tierContributorLimit,
        uint tierMaxContribution,
        uint tierMinContribution,
        string tierRewards
    ) {
        ProjectTier memory tier = pendingContributionTiers[_index];

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
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

    function createBounty (string _bountyName) public devRestricted {
        Bounty newBounty = new Bounty(_bountyName);

        bounties.push(newBounty);
    }

    function() public payable { }
}
