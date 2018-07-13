pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "../storage/ProjectStorageAccess.sol";

library ProjectTimelineProposalLib {

    using ProjectStorageAccess for address;

    function proposeNewTimeline(address _pStorage, uint _projectId) external {
        // Can only suggest new timeline if one already exists
        require(_pStorage.getTimelineIsActive(_projectId), "New timeline cannot be proposed if there is no current active timeline.");
        // Can only suggest new timeline if there is not currently a vote on milestone completion
        require(!_pStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "New timeline cannot be proposed if there is an active vote on milestone completion.");

        verifyPendingTimelinePercentages(_pStorage, _projectId);

        _pStorage.setTimelineProposalTimestamp(_projectId, now);
        _pStorage.setTimelineProposalIsActive(_projectId, true);
    }

    function verifyPendingTimelinePercentages(address _pStorage, uint _projectId) private view {
        // If project has a timeline, verify:
        // - Milestones are present
        // - Milestone percentages add up to 100
        if (!_pStorage.getNoTimeline(_projectId)) {
            uint pendingTimelineLength = _pStorage.getPendingTimelineLength(_projectId);
            require(pendingTimelineLength > 0, "Pending timeline is empty.");

            uint percentageAcc = 0;
            for (uint i = 0; i < pendingTimelineLength; i++) {
                percentageAcc += _pStorage.getPendingTimelineMilestonePercentage(_projectId, i);
            }

            require(percentageAcc == 100, "Milestone percentages must add to 100.");
        }
    }

    function voteOnTimelineProposal(address _pStorage, uint _projectId, bool _approved) external {
        // TimelineProposal must be active
        require(_pStorage.getTimelineProposalIsActive(_projectId), "No timeline proposal active.");

        // Contributor must not have already voted
        require(!_pStorage.getTimelineProposalHasVoted(_projectId, msg.sender), "This contributor address has already voted.");

        if (_approved) {
            uint currentApprovalCount = _pStorage.getTimelineProposalApprovalCount(_projectId);
            _pStorage.setTimelineProposalApprovalCount(_projectId, currentApprovalCount + 1);
        } else {
            uint currentDisapprovalCount = _pStorage.getTimelineProposalDisapprovalCount(_projectId);
            _pStorage.setTimelineProposalDisapprovalCount(_projectId, currentDisapprovalCount + 1);
        }

        _pStorage.setTimelineProposalIsActive(_projectId, true);
    }

    function succeedTimelineProposal(address _pStorage, uint _projectId) external {
        // Set current timeline to inactive
        _pStorage.setTimelineIsActive(_projectId, false);

        // Push old timeline into timeline history
        uint historyLength = _pStorage.getTimelineHistoryLength(_projectId);
        uint timelineLength = _pStorage.getTimelineLength(_projectId);

        for (uint i = 0; i < timelineLength; i++) {
            ProjectStorageAccess.Milestone memory milestone = _pStorage._getTimelineMilestone(_projectId, i);
            _pStorage.setTimelineHistoryMilestoneTitle(_projectId, historyLength, i, milestone.title);
            _pStorage.setTimelineHistoryMilestoneDescription(_projectId, historyLength, i, milestone.description);
            _pStorage.setTimelineHistoryMilestonePercentage(_projectId, historyLength, i, milestone.percentage);
            _pStorage.setTimelineHistoryMilestoneIsComplete(_projectId, historyLength, i, milestone.isComplete);
        }

        _pStorage.setTimelineHistoryLength(_projectId, historyLength + 1);
        _pStorage.setTimelineHistoryMilestonesLength(_projectId, historyLength, timelineLength);

        // Move pending timeline into timeline
        uint pendingTimelineLength = _pStorage.getPendingTimelineLength(_projectId);

        for (uint j = 0; j < pendingTimelineLength; j++) {
            ProjectStorageAccess.Milestone memory pendingMilestone = _pStorage._getPendingTimelineMilestone(_projectId, j);
            _pStorage.setTimelineMilestone(_projectId, j, pendingMilestone.title, pendingMilestone.description, pendingMilestone.percentage, pendingMilestone.isComplete);
        }

        _pStorage.setTimelineLength(_projectId, pendingTimelineLength);

        // Set timeline to be active
        _pStorage.setTimelineIsActive(_projectId, true);

        // Delete pending timeline
        _pStorage.deletePendingTimeline(_projectId);

        // Set timeline proposal to inactive
        _pStorage.setTimelineProposalIsActive(_projectId, false);
    }
}
