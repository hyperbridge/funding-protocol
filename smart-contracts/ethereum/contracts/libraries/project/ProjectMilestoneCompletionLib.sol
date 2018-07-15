pragma solidity ^0.4.24;

import "../storage/ProjectStorageAccess.sol";

library ProjectMilestoneCompletionLib {

    using ProjectStorageAccess for address;

    function submitMilestoneCompletion(address _fundingStorage, uint _projectId, string _report) external {
        // Can only submit for milestone completion if timeline is active
        require(_fundingStorage.getTimelineIsActive(_projectId), "There is no active timeline.");
        // Can only submit for milestone completion if there is not already a vote on milestone completion
        require(!_fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "There is already a vote on milestone completion active.");
        // Can only submit for milestone completion if there is not already a vote on a timeline proposal
        require(!_fundingStorage.getTimelineProposalIsActive(_projectId), "Cannot submit milestone completion if there is an active vote to change the timeline.");

        _fundingStorage.setMilestoneCompletionSubmission(_projectId, now, 0, 0, _report, true, false);
    }

    function voteOnMilestoneCompletion(address _fundingStorage, uint _projectId, bool _approved) external {
        // MilestoneCompletionSubmission must be active
        require(_fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        // Contributor must not have already voted
        require(!_fundingStorage.getMilestoneCompletionSubmissionHasVoted(_projectId, msg.sender), "This contributor address has already voted.");


        if (_approved) {
            uint currentApprovalCount = _fundingStorage.getMilestoneCompletionSubmissionApprovalCount(_projectId);
            _fundingStorage.setMilestoneCompletionSubmissionApprovalCount(_projectId, currentApprovalCount + 1);
        } else {
            uint currentDisapprovalCount = _fundingStorage.getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
            _fundingStorage.setMilestoneCompletionSubmissionDisapprovalCount(_projectId, currentDisapprovalCount + 1);
        }

        _fundingStorage.setMilestoneCompletionSubmissionIsActive(_projectId, true);
    }

    function succeedMilestoneCompletion(address _fundingStorage, uint _projectId) external {
        uint activeIndex = _fundingStorage.getActiveMilestoneIndex(_projectId);
        _fundingStorage.setTimelineMilestoneIsComplete(_projectId, activeIndex, true);

        // Update completedMilestones, remove any pending milestones, and add the completed milestones + current active
        // milestone to the start of the pending timeline. This is to ensure that any future timeline proposals take
        // into account the milestones that have already released their funds.

        // Update completed milestones
        uint completedMilestonesLength = _fundingStorage.getCompletedMilestonesLength(_projectId);

        ProjectStorageAccess.Milestone memory activeMilestone = _fundingStorage._getTimelineMilestone(_projectId, activeIndex);

        _fundingStorage.setCompletedMilestone(_projectId, completedMilestonesLength, activeMilestone.title, activeMilestone.description, activeMilestone.percentage, activeMilestone.isComplete);

        _fundingStorage.setCompletedMilestonesLength(_projectId, completedMilestonesLength + 1);
        completedMilestonesLength++;

        // Remove pending timeline
        _fundingStorage.deletePendingTimeline(_projectId);

        // Increase developer reputation
        // TODO - fs.updateDeveloperReputation(getDeveloperId(_projectId), fs.MILESTONE_COMPLETION_REP_CHANGE());

        // Set milestone completion submission to inactive
        _fundingStorage.setMilestoneCompletionSubmissionIsActive(_projectId, false);

        /* Add the completed milestones + current active milestone to the start of the pending timeline. This is to
          ensure that any future timeline proposals take into account the milestones that have already released their
          funds.
        */
        for (uint i = 0; i < completedMilestonesLength; i++) {
            ProjectStorageAccess.Milestone memory completedMilestone = _fundingStorage._getCompletedMilestone(_projectId, i);
            _fundingStorage.setPendingTimelineMilestone(_projectId, i, completedMilestone.title, completedMilestone.description, completedMilestone.percentage, completedMilestone.isComplete);
        }

        _fundingStorage.setPendingTimelineLength(_projectId, completedMilestonesLength);

        // Increment active milestone and release funds if this was not the last milestone
        if (activeIndex < _fundingStorage.getTimelineLength(_projectId) - 1) {
            // Increment the active milestone
            _fundingStorage.setActiveMilestoneIndex(_projectId, activeIndex + 1);
            activeIndex++;

            // Add currently active milestone to pendingTimeline
            ProjectStorageAccess.Milestone memory currentMilestone = _fundingStorage._getTimelineMilestone(_projectId, activeIndex);

            uint pendingTimelineLength = _fundingStorage.getPendingTimelineLength(_projectId);

            _fundingStorage.setPendingTimelineMilestone(_projectId, pendingTimelineLength, currentMilestone.title, currentMilestone.description, currentMilestone.percentage, currentMilestone.isComplete);
            _fundingStorage.setPendingTimelineLength(_projectId, pendingTimelineLength + 1);

            // todo - transfer funds from vault (through funding service) to developer
        }
    }
}
