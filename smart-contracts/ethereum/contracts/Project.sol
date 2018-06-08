pragma solidity ^0.4.23;
import "./FundingService.sol";

contract Project {

    struct ProjectTimeline {
        ProjectMilestone[] milestones;
        bool isActive;
    }

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

    struct TimelineProposal {
        uint timestamp;
        uint approvalCount;
        uint disapprovalCount;
        bool isActive;
        mapping(address => bool) voters;
    }

    struct MilestoneCompletionSubmission {
        uint timestamp;
        uint approvalCount;
        uint milestoneIndex;
        mapping(address => bool) voters;
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
    ProjectTimeline timeline;
    ProjectTimeline[] timelineHistory;
    ProjectTimeline pendingTimeline;
    TimelineProposal timelineProposal;

    modifier devRestricted() {
        require(msg.sender == developer);
        _;
    }

    modifier contributorRestricted() {
        FundingService fs = FundingService(fundingService);
        require(fs.projectContributionAmount(this, msg.sender) != 0);
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

    function addMilestone(string _milestoneTitle, string _milestoneDescription, uint _percentage, bool _isPending) public devRestricted {
        require(_percentage <= 100);

        ProjectMilestone memory newMilestone = ProjectMilestone({
            title: _milestoneTitle,
            description: _milestoneDescription,
            percentage: _percentage,
            isComplete: false
            });

        if (_isPending) {
            // There must not be an active timeline proposal
            require(timelineProposal.isActive);
            pendingTimeline.milestones.push(newMilestone);
        } else {
            // Timeline must not already be active
            require(!timeline.isActive);
            timeline.milestones.push(newMilestone);
        }
    }

    function getTimelineMilestone(uint _index, bool _isPending) public view
    returns (
        string milestoneTitle,
        string milestoneDescription,
        uint milestonePercentage,
        bool milestoneIsComplete
    ) {
        ProjectMilestone memory milestone;
        if (_isPending) {
            milestone = pendingTimeline.milestones[_index];
        } else {
            milestone = timeline.milestones[_index];
        }
        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function editMilestone(
        uint _index,
        bool _isPending,
        string _milestoneTitle,
        string _milestoneDescription,
        uint _milestonePercentage)
    public devRestricted {
        if (_isPending) {
            // There must not be an active timeline proposal
            require(timelineProposal.isActive);
            ProjectMilestone storage milestone = pendingTimeline.milestones[_index];
        } else {
            // Timeline must not already be active
            require(!timeline.isActive);
            milestone = timeline.milestones[_index];
        }

        milestone.title = _milestoneTitle;
        milestone.description = _milestoneDescription;
        milestone.percentage = _milestonePercentage;
    }

    function initializeTimeline() public fundingServiceRestricted {
        // Check that there isn't already an active timeline
        require(!timeline.isActive);

        // Set timeline to active
        timeline.isActive = true;

        // Change project status to "Pending"
        status = Status.Pending;
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

    function proposeNewTimeline() public devRestricted {
        // Can only suggest new timeline if one already exists
        require(timeline.isActive);

        TimelineProposal memory newProposal = TimelineProposal({
            timestamp: now,
            approvalCount: 0,
            disapprovalCount: 0,
            isActive: true
            });

        timelineProposal = newProposal;
    }

    function getTimelineProposalIsActive() public view returns (bool) {
        return timelineProposal.isActive;
    }

    function getTimelineIsActive() public view returns (bool) {
        return timeline.isActive;
    }

    function hasVotedOnTimelineProposal() public view returns (bool) {
        return timelineProposal.voters[msg.sender];
    }

    function voteOnTimelineProposal(bool approved) public contributorRestricted {
        // TimelineProposal must be active
        require(timelineProposal.isActive == true);

        // Contributor must not have already voted
        require(!timelineProposal.voters[msg.sender]);

        if (approved) {
            timelineProposal.approvalCount++;
        } else {
            timelineProposal.disapprovalCount++;
        }
        timelineProposal.voters[msg.sender] = true;
    }

    function finalizeTimelineProposal() public devRestricted {
        // TimelineProposal must be active
        require(timelineProposal.isActive == true);

        FundingService fs = FundingService(fundingService);
        uint numContributors = fs.getProjectContributorList(this).length;
        uint numVoters = timelineProposal.approvalCount + timelineProposal.disapprovalCount;
        bool isTwoWeeksLater = now >= timelineProposal.timestamp + 2 weeks;
        uint votingThreshold = numVoters * 75 / 100;

        // Proposal needs >75% total approval, or for 2 days to have passed and >75% approval among voters
        require((timelineProposal.approvalCount > numContributors * 75 / 100) ||
            (isTwoWeeksLater && timelineProposal.approvalCount > votingThreshold));

        timeline.isActive = false;
        timelineHistory.push(timeline);
        timeline = pendingTimeline;
        timeline.isActive = true;
        delete(timelineProposal);
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

    function() public payable { }
}
