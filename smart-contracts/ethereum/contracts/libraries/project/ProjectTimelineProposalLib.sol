pragma solidity ^0.4.24;

import "../storage/ProjectStorageAccess.sol";

library ProjectTimelineProposalLib {

    using ProjectStorageAccess for address;

    function proposeNewTimeline(address _fundingStorage, uint _projectId) external {
        // Can only suggest new timeline if one already exists
        require(_fundingStorage.getTimelineIsActive(_projectId), "New timeline cannot be proposed if there is no current active timeline.");
        // Can only suggest new timeline if there is not currently a vote on milestone completion
        require(!_fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "New timeline cannot be proposed if there is an active vote on milestone completion.");

        verifyPendingTimelinePercentages(_fundingStorage, _projectId);

        _fundingStorage.setTimelineProposalTimestamp(_projectId, now);
        _fundingStorage.setTimelineProposalIsActive(_projectId, true);
    }

    function verifyPendingTimelinePercentages(address _fundingStorage, uint _projectId) private view {
        // If project has a timeline, verify:
        // - Milestones are present
        // - Milestone percentages add up to 100
        if (!_fundingStorage.getNoTimeline(_projectId)) {
            uint pendingTimelineLength = _fundingStorage.getPendingTimelineLength(_projectId);
            require(pendingTimelineLength > 0, "Pending timeline is empty.");

            uint percentageAcc = 0;
            for (uint i = 0; i < pendingTimelineLength; i++) {
                percentageAcc += _fundingStorage.getPendingTimelineMilestonePercentage(_projectId, i);
            }

            require(percentageAcc == 100, "Milestone percentages must add to 100.");
        }
    }

    function voteOnTimelineProposal(address _fundingStorage, uint _projectId, bool _approved) external {
        // TimelineProposal must be active
        require(_fundingStorage.getTimelineProposalIsActive(_projectId), "No timeline proposal active.");

        // Contributor must not have already voted
        require(!_fundingStorage.getTimelineProposalHasVoted(_projectId, msg.sender), "This contributor address has already voted.");

        if (_approved) {
            uint currentApprovalCount = _fundingStorage.getTimelineProposalApprovalCount(_projectId);
            _fundingStorage.setTimelineProposalApprovalCount(_projectId, currentApprovalCount + 1);
        } else {
            uint currentDisapprovalCount = _fundingStorage.getTimelineProposalDisapprovalCount(_projectId);
            _fundingStorage.setTimelineProposalDisapprovalCount(_projectId, currentDisapprovalCount + 1);
        }

        _fundingStorage.setTimelineProposalIsActive(_projectId, true);
    }

    function succeedTimelineProposal(address _fundingStorage, uint _projectId) external {
        // Set current timeline to inactive
        _fundingStorage.setTimelineIsActive(_projectId, false);

        // Push old timeline into timeline history
        uint historyLength = _fundingStorage.getTimelineHistoryLength(_projectId);
        uint timelineLength = _fundingStorage.getTimelineLength(_projectId);

        for (uint i = 0; i < timelineLength; i++) {
            ProjectStorageAccess.Milestone memory milestone = _fundingStorage._getTimelineMilestone(_projectId, i);
            _fundingStorage.setTimelineHistoryMilestoneTitle(_projectId, historyLength, i, milestone.title);
            _fundingStorage.setTimelineHistoryMilestoneDescription(_projectId, historyLength, i, milestone.description);
            _fundingStorage.setTimelineHistoryMilestonePercentage(_projectId, historyLength, i, milestone.percentage);
            _fundingStorage.setTimelineHistoryMilestoneIsComplete(_projectId, historyLength, i, milestone.isComplete);
        }

        _fundingStorage.setTimelineHistoryLength(_projectId, historyLength + 1);
        _fundingStorage.setTimelineHistoryMilestonesLength(_projectId, historyLength, timelineLength);

        // Move pending timeline into timeline
        uint pendingTimelineLength = _fundingStorage.getPendingTimelineLength(_projectId);

        for (uint j = 0; j < pendingTimelineLength; j++) {
            ProjectStorageAccess.Milestone memory pendingMilestone = _fundingStorage._getPendingTimelineMilestone(_projectId, j);
            _fundingStorage.setTimelineMilestone(_projectId, j, pendingMilestone.title, pendingMilestone.description, pendingMilestone.percentage, pendingMilestone.isComplete);
        }

        _fundingStorage.setTimelineLength(_projectId, pendingTimelineLength);

        // Set timeline to be active
        _fundingStorage.setTimelineIsActive(_projectId, true);

        // Delete pending timeline
        _fundingStorage.deletePendingTimeline(_projectId);

        // Set timeline proposal to inactive
        _fundingStorage.setTimelineProposalIsActive(_projectId, false);
    }
}
