pragma solidity ^0.4.23 ;
import "./FundingService.sol";

contract Project {

    struct Timeline {
        Milestone[] milestones;
        bool isActive;
    }

    struct Milestone {
        string title;
        string description;
        uint percentage;
        bool isComplete;
    }

    struct ContributionTier {
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
        bool hasFailed;
        mapping(address => bool) voters;
    }

    struct MilestoneCompletionSubmission {
        uint timestamp;
        uint approvalCount;
        uint disapprovalCount;
        string report;
        bool isActive;
        bool hasFailed;
        mapping(address => bool) voters;
    }

    enum Status {Draft, Pending, Published, Removed, Rejected}

    uint public constant MILESTONE_COMPLETION_REP_CHANGE = 5;

    address public fundingService;
    uint public id;
    Status public status;
    string public title;
    string public description;
    string public about;
    address public developer;
    uint public developerId;
    uint public contributionGoal;
    ContributionTier[] contributionTiers;
    ContributionTier[] pendingContributionTiers;
    bool public noRefunds;
    bool public noTimeline;
    Timeline timeline;
    uint public activeMilestoneIndex;
    Milestone[] completedMilestones;
    Timeline[] timelineHistory;
    Timeline pendingTimeline;
    TimelineProposal timelineProposal;
    MilestoneCompletionSubmission milestoneCompletionSubmission;

    modifier devRestricted() {
        require(msg.sender == developer, "Caller is not the developer of this project.");
        _;
    }

    modifier contributorRestricted() {
        FundingService fs = FundingService(fundingService);
        require(fs.projectContributionAmount(this, msg.sender) != 0, "Caller is not a contributor to this project.");
        _;
    }

    modifier fundingServiceRestricted() {
        require(msg.sender == fundingService, "This action can only be performed by the Funding Service.");
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

    function () public payable {
        revert();
    }

    function addMilestone(string _milestoneTitle, string _milestoneDescription, uint _percentage, bool _isPending) public devRestricted {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");
        require(!noTimeline, "Cannot add a milestone to a project with no timeline.");

        Milestone memory newMilestone = Milestone({
            title: _milestoneTitle,
            description: _milestoneDescription,
            percentage: _percentage,
            isComplete: false
            });

        if (_isPending) {
            // There must not be an active timeline proposal
            require(!timelineProposal.isActive, "Pending milestones cannot be added while a timeline proposal vote is active.");
            // There must be an active timeline already
            require(timeline.isActive, "Pending milestones cannot be added when there is not a timeline currently active.");

            pendingTimeline.milestones.push(newMilestone);
        } else {
            // Timeline must not already be active
            require(!timeline.isActive, "Milestone cannot be added to an active timeline.");
            timeline.milestones.push(newMilestone);
        }
    }

    function getMilestone(uint _index, bool _isPending) public view
    returns (
        string milestoneTitle,
        string milestoneDescription,
        uint milestonePercentage,
        bool milestoneIsComplete
    ) {
        Milestone memory milestone;
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
        require(_milestonePercentage <= 100, "Milestone percentage cannot be greater than 100.");

        if (_isPending) {
            // There must not be an active timeline proposal
            require(!timelineProposal.isActive, "Pending milestones cannot be edited while a timeline proposal vote is active.");

            Milestone storage milestone = pendingTimeline.milestones[_index];
        } else {
            // Timeline must not already be active
            require(!timeline.isActive, "Milestone cannot be edited in an active timeline.");

            milestone = timeline.milestones[_index];
        }

        milestone.title = _milestoneTitle;
        milestone.description = _milestoneDescription;
        milestone.percentage = _milestonePercentage;
    }

    function clearPendingTimeline() public devRestricted {
        // There must not be an active timeline proposal
        require(!timelineProposal.isActive, "Pending milestones cannot be edited while a timeline proposal vote is active.");

        delete(pendingTimeline);
        pendingTimeline.milestones = completedMilestones;
        pendingTimeline.milestones.push(timeline.milestones[activeMilestoneIndex]);
    }

    function initializeTimeline() public fundingServiceRestricted {
        // Check that there isn't already an active timeline
        require(!timeline.isActive, "Timeline has already been initialized.");

        // Set timeline to active
        timeline.isActive = true;

        // Set first milestone as active
        activeMilestoneIndex = 0;

        // Change project status to "Pending"
        status = Status.Pending;
    }

    function getTimelineIsActive() public view returns (bool) {
        return timeline.isActive;
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

    function verifyPendingTimelinePercentages() private view {
        // If project has a timeline, verify:
        // - Milestones are present
        // - Milestone percentages add up to 100
        if (!noTimeline) {
            require(pendingTimeline.milestones.length > 0, "Pending timeline is empty.");

            uint percentageAcc = 0;
            for (uint i = 0; i < pendingTimeline.milestones.length; i++) {
                percentageAcc += pendingTimeline.milestones[i].percentage;
            }
            require(percentageAcc == 100, "Milestone percentages must add to 100.");
        }
    }

    function proposeNewTimeline() public devRestricted {
        // Can only suggest new timeline if one already exists
        require(timeline.isActive, "New timeline cannot be proposed if there is no current active timeline.");
        // Can only suggest new timeline if there is not currently a vote on milestone completion
        require(!milestoneCompletionSubmission.isActive, "New timeline cannot be proposed if there is an active vote on milestone completion.");

        verifyPendingTimelinePercentages();

        TimelineProposal memory newProposal = TimelineProposal({
            timestamp: now,
            approvalCount: 0,
            disapprovalCount: 0,
            isActive: true,
            hasFailed: false
            });

        timelineProposal = newProposal;
    }

    function getTimelineProposal() public view returns (uint timestamp, uint approvalCount, uint disapprovalCount, bool isActive, bool hasFailed) {
        return (timelineProposal.timestamp, timelineProposal.approvalCount, timelineProposal.disapprovalCount, timelineProposal.isActive, timelineProposal.hasFailed);
    }

    function voteOnTimelineProposal(bool approved) public contributorRestricted {
        // TimelineProposal must be active
        require(timelineProposal.isActive == true, "No timeline proposal active.");

        // Contributor must not have already voted
        require(!timelineProposal.voters[msg.sender], "This contributor address has already voted.");

        if (approved) {
            timelineProposal.approvalCount++;
        } else {
            timelineProposal.disapprovalCount++;
        }
        timelineProposal.voters[msg.sender] = true;
    }

    function hasVotedOnTimelineProposal() public view returns (bool) {
        return timelineProposal.voters[msg.sender];
    }

    function finalizeTimelineProposal() public devRestricted {
        // TimelineProposal must be active
        require(timelineProposal.isActive == true, "There is no timeline proposal active.");

        FundingService fs = FundingService(fundingService);
        uint numContributors = fs.getProjectContributorList(this).length;
        uint numVoters = timelineProposal.approvalCount + timelineProposal.disapprovalCount;
        bool isTwoWeeksLater = now >= timelineProposal.timestamp + 2 weeks;
        uint votingThreshold = numVoters * 75 / 100;

        // Proposal needs >75% total approval, or for 2 weeks to have passed and >75% approval among voters
        require((timelineProposal.approvalCount > numContributors * 75 / 100) ||
            (isTwoWeeksLater && timelineProposal.approvalCount > votingThreshold),
            "Conditions for finalizing timeline proposal have not yet been achieved.");

        if (timelineProposal.approvalCount > votingThreshold) {
            timeline.isActive = false;
            timelineHistory.push(timeline);
            timeline = pendingTimeline;
            timeline.isActive = true;
            delete(timelineProposal);
            delete(pendingTimeline);
        } else {
            // TimelineProposal has failed
            timelineProposal.hasFailed = true;
        }
    }

    function submitMilestoneCompletion(string _report) public devRestricted {
        // Can only submit for milestone completion if timeline is active
        require(timeline.isActive, "There is no active timeline.");
        // Can only submit for milestone completion if there is not already a vote on milestone completion
        require(!milestoneCompletionSubmission.isActive, "There is already a vote on milestone completion active.");
        // Can only submit for milestone completion if there is not already a vote on a timeline proposal
        require(!timelineProposal.isActive, "Cannot submit milestone completion if there is an active vote to change the timeline.");

        MilestoneCompletionSubmission memory newSubmission = MilestoneCompletionSubmission({
            timestamp: now,
            approvalCount: 0,
            disapprovalCount: 0,
            report: _report,
            isActive: true,
            hasFailed: false
            });

        milestoneCompletionSubmission = newSubmission;
    }

    function getMilestoneCompletionSubmission() public view returns (uint timestamp, uint approvalCount, uint disapprovalCount, string report, bool isActive, bool hasFailed) {
        return (milestoneCompletionSubmission.timestamp, milestoneCompletionSubmission.approvalCount, milestoneCompletionSubmission.disapprovalCount, milestoneCompletionSubmission.report, milestoneCompletionSubmission.isActive, milestoneCompletionSubmission.hasFailed);
    }

    function voteOnMilestoneCompletion(bool approved) public contributorRestricted {
        // MilestoneCompletionSubmission must be active
        require(milestoneCompletionSubmission.isActive == true, "No vote on milestone completion active.");

        // Contributor must not have already voted
        require(!milestoneCompletionSubmission.voters[msg.sender], "This contributor address has already voted.");

        if (approved) {
            milestoneCompletionSubmission.approvalCount++;
        } else {
            milestoneCompletionSubmission.disapprovalCount++;
        }
        milestoneCompletionSubmission.voters[msg.sender] = true;
    }

    function hasVotedOnMilestoneCompletion() public view returns (bool) {
        return milestoneCompletionSubmission.voters[msg.sender];
    }

    function finalizeMilestoneCompletion() public devRestricted {
        // MilestoneCompletionSubmission must be active
        require(milestoneCompletionSubmission.isActive == true, "No vote on milestone completion active.");

        FundingService fs = FundingService(fundingService);
        uint numContributors = fs.getProjectContributorList(this).length;
        uint numVoters = milestoneCompletionSubmission.approvalCount + milestoneCompletionSubmission.disapprovalCount;
        bool isTwoWeeksLater = now >= milestoneCompletionSubmission.timestamp + 2 weeks;
        uint votingThreshold = numVoters * 75 / 100;

        // Proposal needs >75% total approval, or for 2 days to have passed and >75% approval among voters
        require((milestoneCompletionSubmission.approvalCount > numContributors * 75 / 100) ||
            (isTwoWeeksLater && milestoneCompletionSubmission.approvalCount > votingThreshold),
            "Conditions for finalizing milestone completion have not yet been achieved.");

        timeline.milestones[activeMilestoneIndex].isComplete = true;

        // Update completedMilestones, remove any pending milestones, and add the completed milestones + current active
        // milestone to the start of the pending timeline. This is to ensure that any future timeline proposals take
        // into account the milestones that have already released their funds.
        completedMilestones.push(timeline.milestones[activeMilestoneIndex]);

        delete(pendingTimeline);
        pendingTimeline.milestones = completedMilestones;

        delete(milestoneCompletionSubmission);

        // Increase developer reputation
        fs.updateDeveloperReputation(developerId, MILESTONE_COMPLETION_REP_CHANGE);

        // Increment active milestone and release funds if this was not the last milestone
        if (activeMilestoneIndex < timeline.milestones.length - 1) {
            // Increment the active milestone
            activeMilestoneIndex++;

            // Add currently active milestone to pendingTimeline
            pendingTimeline.milestones.push(timeline.milestones[activeMilestoneIndex]);

            // todo - transfer funds from vault (through funding service) to developer
        }
    }

    function setStatus(Status _status) public fundingServiceRestricted {
        status = _status;
    }

    function setNoRefunds(bool val) public devRestricted {
        require(status == Status.Draft, "This action can only be performed on a draft project.");
        noRefunds = val;
    }

    function setNoTimeline(bool val) public devRestricted {
        require(status == Status.Draft, "This action can only be performed on a draft project.");
        if (val) {
            delete(timeline);
        }
        noTimeline = val;
    }

    function addTier(uint _contributorLimit, uint _maxContribution, uint _minContribution, string _rewards) public devRestricted {
        ContributionTier memory newTier = ContributionTier({
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
        ContributionTier storage tier = pendingContributionTiers[_index];

        tier.contributorLimit = _contributorLimit;
        tier.maxContribution = _maxContribution;
        tier.minContribution = _minContribution;
        tier.rewards = _rewards;
    }

    function getContributionTier(uint _index) public view
    returns (
        uint tierContributorLimit,
        uint tierMaxContribution,
        uint tierMinContribution,
        string tierRewards
    ) {
        ContributionTier memory tier = contributionTiers[_index];

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
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
        ContributionTier memory tier = pendingContributionTiers[_index];

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
    }

    function finalizeTiers() public devRestricted {
        contributionTiers = pendingContributionTiers;

        delete(pendingContributionTiers);
    }
}
