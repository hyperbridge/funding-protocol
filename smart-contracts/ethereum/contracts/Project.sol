pragma solidity ^0.4.24;

import "./ProjectStorageAccess.sol";
import "./FundingService.sol";

contract Project is ProjectStorageAccess {

    enum Status {Draft, Pending, Published, Removed, Rejected}

    // TODO - rethink modifiers
    //    modifier devRestricted() {
    //        require(msg.sender == developer, "Caller is not the developer of this project.");
    //        _;
    //    }
    //
    //    modifier contributorRestricted() {
    //        FundingService fs = FundingService(fundingService);
    //        require(fs.projectContributionAmount(this, msg.sender) != 0, "Caller is not a contributor to this project.");
    //        _;
    //    }
    //
    //    modifier fundingServiceRestricted() {
    //        require(msg.sender == fundingService, "This action can only be performed by the Funding Service.");
    //        _;
    //    }

    address fundingService;

    constructor(address _projectStorage, address _fundingService) public {
        pStorage = ProjectStorage(_projectStorage);
        fundingService = _fundingService;
    }

    function createProject(
        string _title,
        string _description,
        string _about,
        uint _contributionGoal,
        address _developer,
        uint _developerId
    )
    public
    {
        // Get next ID from storage
        uint id = _getNextId();
        // Increment next ID
        incrementNextId();

        _setProject(id, uint(Status.Draft), _title, _description, _about, _developer, _developerId, _contributionGoal);
    }

    function addMilestone(
        uint _projectId,
        string _title,
        string _description,
        uint _percentage,
        bool _isPending
    )
    public
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");
        require(!_getNoTimeline(_projectId), "Cannot add a milestone to a project with no timeline.");

        if (_isPending) {
            // There must not be an active timeline proposal
            require(!_getTimelineProposalIsActive(_projectId), "Pending milestones cannot be added while a timeline proposal vote is active.");
            // There must be an active timeline already
            require(_getTimelineIsActive(_projectId), "Pending milestones cannot be added when there is not a timeline currently active.");

            // Get next available milestone index
            uint index = _getPendingTimelineLength(_projectId);

            _setPendingTimelineMilestone(_projectId, index, _title, _description, _percentage, false);

            // Increment pending timeline length
            _setPendingTimelineLength(_projectId, index + 1);
        } else {
            // Timeline must not already be active
            require(!_getTimelineIsActive(_projectId), "Milestone cannot be added to an active timeline.");

            // _get next available milestone index
            index = _getTimelineLength(_projectId);

            _setTimelineMilestone(_projectId, index, _title, _description, _percentage, false);

            // Increment timeline length
            _setTimelineLength(_projectId, index + 1);
        }
    }

    function getMilestone(
        uint _projectId,
        uint _index,
        bool _isPending
    )
    public
    view
    returns (
        string milestoneTitle,
        string milestoneDescription,
        uint milestonePercentage,
        bool milestoneIsComplete
    )
    {
        Milestone memory milestone;
        if (_isPending) {
            milestone = _getPendingTimelineMilestone(_projectId, _index);
        } else {
            milestone = _getTimelineMilestone(_projectId, _index);
        }
        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function editMilestone(
        uint _projectId,
        uint _index,
        bool _isPending,
        string _title,
        string _description,
        uint _percentage
    )
    public
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");

        if (_isPending) {
            // There must not be an active timeline proposal
            require(!_getTimelineProposalIsActive(_projectId), "Pending milestones cannot be edited while a timeline proposal vote is active.");
            // This milestone must not be completed
            require(!_getPendingTimelineMilestoneIsComplete(_projectId, _index), "Cannot edit a completed milestone.");

            _setPendingTimelineMilestone(_projectId, _index, _title, _description, _percentage, false);
        } else {
            // Timeline must not be active
            require(!_getTimelineIsActive(_projectId), "Milestones in an active timeline cannot be edited.");
            // This milestone must not be completed
            require(!_getTimelineMilestoneIsComplete(_projectId, _index), "Cannot edit a completed milestone.");

            _setTimelineMilestone(_projectId, _index, _title, _description, _percentage, false);
        }
    }

    function clearPendingTimeline(uint _projectId) public {
        // There must not be an active timeline proposal
        require(!_getTimelineProposalIsActive(_projectId), "A timeline proposal vote is active.");

        _deletePendingTimeline(_projectId);

        uint completedMilestonesLength = _getCompletedMilestonesLength(_projectId);

        for (uint i = 0; i < completedMilestonesLength; i++) {
            Milestone memory completedMilestone = _getCompletedMilestone(_projectId, i);
            _setPendingTimelineMilestone(
                _projectId,
                i,
                completedMilestone.title,
                completedMilestone.description,
                completedMilestone.percentage,
                completedMilestone.isComplete
            );
        }

        uint activeMilestoneIndex = _getActiveMilestoneIndex(_projectId);

        Milestone memory activeMilestone = _getTimelineMilestone(_projectId, activeMilestoneIndex);
        _setPendingTimelineMilestone(
            _projectId,
            completedMilestonesLength,
            activeMilestone.title,
            activeMilestone.description,
            activeMilestone.percentage,
            activeMilestone.isComplete
        );

        _setPendingTimelineLength(_projectId, completedMilestonesLength + 1);
    }

    function initializeTimeline(uint _projectId) public {
        // Check that there isn't already an active timeline
        require(!_getTimelineIsActive(_projectId), "Timeline has already been initialized.");

        // Set timeline to active
        _setTimelineIsActive(_projectId, true);

        // Set first milestone as active
        _setActiveMilestoneIndex(_projectId, 0);

        // Change project status to "Pending"
        _setStatus(_projectId, uint(Status.Pending));
    }

    function getTimelineIsActive(uint _projectId) public view returns (bool) {
        return _getTimelineIsActive(_projectId);
    }

    function getPendingTimelineLength(uint _projectId) public view returns (uint) {
        return _getPendingTimelineLength(_projectId);
    }

    function getTimelineLength(uint _projectId) public view returns (uint) {
        return _getTimelineLength(_projectId);
    }

    function getTimelineHistoryLength(uint _projectId) public view returns (uint) {
        return _getTimelineHistoryLength(_projectId);
    }

    function verifyPendingTimelinePercentages(uint _projectId) private view {
        // If project has a timeline, verify:
        // - Milestones are present
        // - Milestone percentages add up to 100
        if (!_getNoTimeline(_projectId)) {
            uint pendingTimelineLength = _getPendingTimelineLength(_projectId);
            require(pendingTimelineLength > 0, "Pending timeline is empty.");

            uint percentageAcc = 0;
            for (uint i = 0; i < pendingTimelineLength; i++) {
                percentageAcc += _getPendingTimelineMilestonePercentage(_projectId, i);
            }
            require(percentageAcc == 100, "Milestone percentages must add to 100.");
        }
    }

    function proposeNewTimeline(uint _projectId) public {
        // Can only suggest new timeline if one already exists
        require(_getTimelineIsActive(_projectId), "New timeline cannot be proposed if there is no current active timeline.");
        // Can only suggest new timeline if there is not currently a vote on milestone completion
        require(!_getMilestoneCompletionSubmissionIsActive(_projectId), "New timeline cannot be proposed if there is an active vote on milestone completion.");

        verifyPendingTimelinePercentages(_projectId);

        _setTimelineProposalTimestamp(_projectId, now);
        _setTimelineProposalIsActive(_projectId, true);
    }

    function getTimelineProposal(uint _projectId) public view
    returns (
        uint timestamp,
        uint approvalCount,
        uint disapprovalCount,
        bool isActive,
        bool hasFailed
    ) {
        TimelineProposal memory proposal = _getTimelineProposal(_projectId);
        return (proposal.timestamp, proposal.approvalCount, proposal.disapprovalCount, proposal.isActive, proposal.hasFailed);
    }

    function voteOnTimelineProposal(uint _projectId, bool _approved) public {
        // TimelineProposal must be active
        require(_getTimelineProposalIsActive(_projectId), "No timeline proposal active.");

        // Contributor must not have already voted
        require(!_getTimelineProposalHasVoted(_projectId, msg.sender), "This contributor address has already voted.");

        if (_approved) {
            uint currentApprovalCount = _getTimelineProposalApprovalCount(_projectId);
            _setTimelineProposalApprovalCount(_projectId, currentApprovalCount + 1);
        } else {
            uint currentDisapprovalCount = _getTimelineProposalDisapprovalCount(_projectId);
            _setTimelineProposalDisapprovalCount(_projectId, currentDisapprovalCount + 1);
        }

        _setTimelineProposalIsActive(_projectId, true);
    }

    function hasVotedOnTimelineProposal(uint _projectId) public view returns (bool) {
        return _getTimelineProposalHasVoted(_projectId, msg.sender);
    }

    function finalizeTimelineProposal(uint _projectId) public {
        // TimelineProposal must be active
        require(_getTimelineProposalIsActive(_projectId), "There is no timeline proposal active.");

        FundingService fs = FundingService(fundingService);
        uint numContributors = fs.getProjectContributorList(_projectId).length;
        uint approvalCount = _getTimelineProposalApprovalCount(_projectId);
        uint disapprovalCount = _getTimelineProposalDisapprovalCount(_projectId);
        uint numVoters = approvalCount + disapprovalCount;
        bool isTwoWeeksLater = now >= _getTimelineProposalTimestamp(_projectId) + 2 weeks;
        uint votingThreshold = numVoters * 75 / 100;

        // Proposal needs >75% total approval, or for 2 weeks to have passed and >75% approval among voters
        require((approvalCount > numContributors * 75 / 100) ||
            (isTwoWeeksLater && approvalCount > votingThreshold),
            "Conditions for finalizing timeline proposal have not yet been achieved.");

        if (approvalCount > votingThreshold) {
            // Set current timeline to inactive
            _setTimelineIsActive(_projectId, false);

            // Push old timeline into timeline history
            uint historyLength = _getTimelineHistoryLength(_projectId);
            uint timelineLength = _getTimelineLength(_projectId);

            for (uint i = 0; i < timelineLength; i++) {
                Milestone memory milestone = _getTimelineMilestone(_projectId, i);
                _setTimelineHistoryMilestone(_projectId, historyLength, i, milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
            }

            _setTimelineHistoryLength(_projectId, historyLength + 1);
            _setTimelineHistoryMilestonesLength(_projectId, historyLength, timelineLength);

            // Move pending timeline into timeline
            uint pendingTimelineLength = _getPendingTimelineLength(_projectId);

            for (uint j = 0; j < pendingTimelineLength; j++) {
                Milestone memory pendingMilestone = _getPendingTimelineMilestone(_projectId, j);
                _setTimelineMilestone(_projectId, j, pendingMilestone.title, pendingMilestone.description, pendingMilestone.percentage, pendingMilestone.isComplete);
            }

            _setTimelineLength(_projectId, pendingTimelineLength);

            // Set timeline to be active
            _setTimelineIsActive(_projectId, true);

            // Delete pending timeline
            _deletePendingTimeline(_projectId);

            // Set timeline proposal to inactive
            _setTimelineProposalIsActive(_projectId, false);
        } else {
            // Timeline proposal has failed
            _setTimelineProposalHasFailed(_projectId, true);
        }
    }

    function submitMilestoneCompletion(uint _projectId, string _report) public {
        // Can only submit for milestone completion if timeline is active
        require(_getTimelineIsActive(_projectId), "There is no active timeline.");
        // Can only submit for milestone completion if there is not already a vote on milestone completion
        require(!_getMilestoneCompletionSubmissionIsActive(_projectId), "There is already a vote on milestone completion active.");
        // Can only submit for milestone completion if there is not already a vote on a timeline proposal
        require(!_getTimelineProposalIsActive(_projectId), "Cannot submit milestone completion if there is an active vote to change the timeline.");

        _setMilestoneCompletionSubmission(_projectId, now, 0, 0, _report, true, false);
    }

    function getMilestoneCompletionSubmission(uint _projectId) public view
    returns (
        uint timestamp,
        uint approvalCount,
        uint disapprovalCount,
        string report,
        bool isActive,
        bool hasFailed
    ) {
        MilestoneCompletionSubmission memory submission = _getMilestoneCompletionSubmission(_projectId);
        return (
        submission.timestamp,
        submission.approvalCount,
        submission.disapprovalCount,
        submission.report,
        submission.isActive,
        submission.hasFailed
        );
    }

    function voteOnMilestoneCompletion(uint _projectId, bool _approved) public {
        // MilestoneCompletionSubmission must be active
        require(_getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        // Contributor must not have already voted
        require(!_getMilestoneCompletionSubmissionHasVoted(_projectId, msg.sender), "This contributor address has already voted.");

        if (_approved) {
            uint currentApprovalCount = _getMilestoneCompletionSubmissionApprovalCount(_projectId);
            _setMilestoneCompletionSubmissionApprovalCount(_projectId, currentApprovalCount + 1);
        } else {
            uint currentDisapprovalCount = _getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
            _setMilestoneCompletionSubmissionDisapprovalCount(_projectId, currentDisapprovalCount + 1);
        }

        _setMilestoneCompletionSubmissionIsActive(_projectId, true);
    }

    function hasVotedOnMilestoneCompletion(uint _projectId) public view returns (bool) {
        return _getMilestoneCompletionSubmissionHasVoted(_projectId, msg.sender);
    }

    function finalizeMilestoneCompletion(uint _projectId) public {
        // MilestoneCompletionSubmission must be active
        require(_getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        FundingService fs = FundingService(fundingService);
        uint numContributors = fs.getProjectContributorList(_projectId).length;
        uint approvalCount = _getMilestoneCompletionSubmissionApprovalCount(_projectId);
        uint disapprovalCount = _getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
        uint numVoters = approvalCount + disapprovalCount;
        bool isTwoWeeksLater = now >= _getMilestoneCompletionSubmissionTimestamp(_projectId) + 2 weeks;
        uint votingThreshold = numVoters * 75 / 100;

        // Proposal needs >75% total approval, or for 2 days to have passed and >75% approval among voters
        require((approvalCount > numContributors * 75 / 100) ||
            (isTwoWeeksLater && approvalCount > votingThreshold),
            "Conditions for finalizing milestone completion have not yet been achieved.");

        uint activeIndex = _getActiveMilestoneIndex(_projectId);
        _setTimelineMilestoneIsComplete(_projectId, activeIndex, true);

        // Update completedMilestones, remove any pending milestones, and add the completed milestones + current active
        // milestone to the start of the pending timeline. This is to ensure that any future timeline proposals take
        // into account the milestones that have already released their funds.

        // Update completed milestones
        uint completedMilestonesLength = _getCompletedMilestonesLength(_projectId);

        Milestone memory activeMilestone = _getTimelineMilestone(_projectId, activeIndex);

        _setCompletedMilestone(_projectId, completedMilestonesLength, activeMilestone.title, activeMilestone.description, activeMilestone.percentage, activeMilestone.isComplete);

        _setCompletedMilestonesLength(_projectId, completedMilestonesLength + 1);
        completedMilestonesLength++;

        // Remove pending timeline
        _deletePendingTimeline(_projectId);

        // Increase developer reputation
        fs.updateDeveloperReputation(_getDeveloperId(_projectId), fs.MILESTONE_COMPLETION_REP_CHANGE());

        // Set milestone completion submission to inactive
        _setMilestoneCompletionSubmissionIsActive(_projectId, false);

        /* Add the completed milestones + current active milestone to the start of the pending timeline. This is to
           ensure that any future timeline proposals take into account the milestones that have already released their
           funds.
        */
        for (uint i = 0; i < completedMilestonesLength; i++) {
            Milestone memory completedMilestone = _getCompletedMilestone(_projectId, i);
            _setPendingTimelineMilestone(_projectId, i, completedMilestone.title, completedMilestone.description, completedMilestone.percentage, completedMilestone.isComplete);
        }

        _setPendingTimelineLength(_projectId, completedMilestonesLength);

        // Increment active milestone and release funds if this was not the last milestone
        if (activeIndex < _getTimelineLength(_projectId) - 1) {
            // Increment the active milestone
            _setActiveMilestoneIndex(_projectId, activeIndex + 1);
            activeIndex++;

            // Add currently active milestone to pendingTimeline
            Milestone memory currentMilestone = _getTimelineMilestone(_projectId, activeIndex);

            uint pendingTimelineLength = _getPendingTimelineLength(_projectId);

            _setPendingTimelineMilestone(_projectId, pendingTimelineLength, currentMilestone.title, currentMilestone.description, currentMilestone.percentage, currentMilestone.isComplete);
            _setPendingTimelineLength(_projectId, pendingTimelineLength + 1);

            // todo - transfer funds from vault (through funding service) to developer
        }
    }

    function setStatus(uint _projectId, Status _status) public {
        _setStatus(_projectId, uint(_status));
    }

    function setNoRefunds(uint _projectId, bool _noRefunds) public {
        require(Status(_getStatus(_projectId)) == Status.Draft, "This action can only be performed on a draft project.");

        _setNoRefunds(_projectId, _noRefunds);
    }

    function setNoTimeline(uint _projectId, bool _noTimeline) public {
        require(Status(_getStatus(_projectId)) == Status.Draft, "This action can only be performed on a draft project.");

        if (_noTimeline) {
            _deleteTimeline(_projectId);
        }

        _setNoTimeline(_projectId, _noTimeline);
    }

    function addTier(uint _projectId, uint _contributorLimit, uint _maxContribution, uint _minContribution, string _rewards) public {
        uint currentLength = _getPendingContributionTiersLength(_projectId);

        _setPendingContributionTier(_projectId, currentLength, _contributorLimit, _maxContribution, _minContribution, _rewards);

        _setPendingContributionTiersLength(_projectId, currentLength + 1);
    }

    function editTier(
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
    public
    {
        _setPendingContributionTier(_projectId, _index, _contributorLimit, _maxContribution, _minContribution, _rewards);
    }

    function getContributionTier(uint _projectId, uint _index) public view
    returns (
        uint tierContributorLimit,
        uint tierMaxContribution,
        uint tierMinContribution,
        string tierRewards
    ) {
        ContributionTier memory tier = _getContributionTier(_projectId, _index);

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
    }

    function getPendingTiersLength(uint _projectId) public view returns (uint) {
        return _getPendingContributionTiersLength(_projectId);
    }

    function getTiersLength(uint _projectId) public view returns (uint) {
        return _getContributionTiersLength(_projectId);
    }

    function getPendingContributionTier(uint _projectId, uint _index) public view
    returns (
        uint tierContributorLimit,
        uint tierMaxContribution,
        uint tierMinContribution,
        string tierRewards
    ) {
        ContributionTier memory tier = _getPendingContributionTier(_projectId, _index);

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
    }

    function finalizeTiers(uint _projectId) public {

        _deleteContributionTiers(_projectId);

        uint length = _getPendingContributionTiersLength(_projectId);

        for (uint i = 0; i < length; i++) {
            ContributionTier memory tier = _getPendingContributionTier(_projectId, i);

            _setContributionTier(_projectId, i, tier.contributorLimit, tier.minContribution, tier.maxContribution, tier.rewards);
        }

        _setContributionTiersLength(_projectId, length);

        _deletePendingContributionTiers(_projectId);
    }
}
