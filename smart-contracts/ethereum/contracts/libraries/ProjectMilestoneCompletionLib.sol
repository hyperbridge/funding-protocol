pragma solidity ^0.4.24;

import "../ProjectEternalStorage.sol";
import "./ProjectStorageAccess.sol";

library ProjectMilestoneCompletionLib {

    using ProjectStorageAccess for address;

    function submitMilestoneCompletion(address _pStorage, uint _projectId, string _report) external {
        // Can only submit for milestone completion if timeline is active
        require(_pStorage.getTimelineIsActive(_projectId), "There is no active timeline.");
        // Can only submit for milestone completion if there is not already a vote on milestone completion
        require(!_pStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "There is already a vote on milestone completion active.");
        // Can only submit for milestone completion if there is not already a vote on a timeline proposal
        require(!_pStorage.getTimelineProposalIsActive(_projectId), "Cannot submit milestone completion if there is an active vote to change the timeline.");

        _pStorage.setMilestoneCompletionSubmission(_projectId, now, 0, 0, _report, true, false);
    }

    function voteOnMilestoneCompletion(address _pStorage, uint _projectId, bool _approved) external {
        // MilestoneCompletionSubmission must be active
        require(_pStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        // Contributor must not have already voted
        require(!_pStorage.getMilestoneCompletionSubmissionHasVoted(_projectId, msg.sender), "This contributor address has already voted.");


        if (_approved) {
            uint currentApprovalCount = _pStorage.getMilestoneCompletionSubmissionApprovalCount(_projectId);
            _pStorage.setMilestoneCompletionSubmissionApprovalCount(_projectId, currentApprovalCount + 1);
        } else {
            uint currentDisapprovalCount = _pStorage.getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
            _pStorage.setMilestoneCompletionSubmissionDisapprovalCount(_projectId, currentDisapprovalCount + 1);
        }

        _pStorage.setMilestoneCompletionSubmissionIsActive(_projectId, true);
    }

    function succeedMilestoneCompletion(address _pStorage, uint _projectId) external {
        uint activeIndex = _pStorage.getActiveMilestoneIndex(_projectId);
        _pStorage.setTimelineMilestoneIsComplete(_projectId, activeIndex, true);

        // Update completedMilestones, remove any pending milestones, and add the completed milestones + current active
        // milestone to the start of the pending timeline. This is to ensure that any future timeline proposals take
        // into account the milestones that have already released their funds.

        // Update completed milestones
        uint completedMilestonesLength = _pStorage.getCompletedMilestonesLength(_projectId);

        ProjectStorageAccess.Milestone memory activeMilestone = _pStorage._getTimelineMilestone(_projectId, activeIndex);

        _pStorage.setCompletedMilestone(_projectId, completedMilestonesLength, activeMilestone.title, activeMilestone.description, activeMilestone.percentage, activeMilestone.isComplete);

        _pStorage.setCompletedMilestonesLength(_projectId, completedMilestonesLength + 1);
        completedMilestonesLength++;

        // Remove pending timeline
        _pStorage.deletePendingTimeline(_projectId);

        // Increase developer reputation
        // TODO - fs.updateDeveloperReputation(getDeveloperId(_projectId), fs.MILESTONE_COMPLETION_REP_CHANGE());

        // Set milestone completion submission to inactive
        _pStorage.setMilestoneCompletionSubmissionIsActive(_projectId, false);

        /* Add the completed milestones + current active milestone to the start of the pending timeline. This is to
          ensure that any future timeline proposals take into account the milestones that have already released their
          funds.
        */
        for (uint i = 0; i < completedMilestonesLength; i++) {
            ProjectStorageAccess.Milestone memory completedMilestone = _pStorage._getCompletedMilestone(_projectId, i);
            _pStorage.setPendingTimelineMilestone(_projectId, i, completedMilestone.title, completedMilestone.description, completedMilestone.percentage, completedMilestone.isComplete);
        }

        _pStorage.setPendingTimelineLength(_projectId, completedMilestonesLength);

        // Increment active milestone and release funds if this was not the last milestone
        if (activeIndex < _pStorage.getTimelineLength(_projectId) - 1) {
            // Increment the active milestone
            _pStorage.setActiveMilestoneIndex(_projectId, activeIndex + 1);
            activeIndex++;

            // Add currently active milestone to pendingTimeline
            ProjectStorageAccess.Milestone memory currentMilestone = _pStorage._getTimelineMilestone(_projectId, activeIndex);

            uint pendingTimelineLength = _pStorage.getPendingTimelineLength(_projectId);

            _pStorage.setPendingTimelineMilestone(_projectId, pendingTimelineLength, currentMilestone.title, currentMilestone.description, currentMilestone.percentage, currentMilestone.isComplete);
            _pStorage.setPendingTimelineLength(_projectId, pendingTimelineLength + 1);

            // todo - transfer funds from vault (through funding service) to developer
        }
    }
}
