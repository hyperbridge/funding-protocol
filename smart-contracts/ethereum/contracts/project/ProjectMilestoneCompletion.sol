pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../Developer.sol";
import "../FundingVault.sol";
import "../libraries/ProjectTimelineHelpersLibrary.sol";

contract ProjectMilestoneCompletion is ProjectBase {

    using ProjectTimelineHelpersLibrary for address;

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = _fundingStorage;
    }

    function submitMilestoneCompletion(uint _projectId, string _report) external onlyProjectDeveloper(_projectId) onlyProjectInDevelopment(_projectId) {
        // Can only submit for milestone completion if there is not already a vote on milestone completion
        require(!fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "There is already a vote on milestone completion active.");
        // Can only submit for milestone completion if there is not already a vote on a timeline proposal
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "Cannot submit milestone completion if there is an active vote to change the timeline.");

        fundingStorage.setMilestoneCompletionSubmission(_projectId, now, 0, 0, _report, true, false);
    }

    function voteOnMilestoneCompletion(uint _projectId, bool _approved) external onlyProjectContributor(_projectId) {
        // MilestoneCompletionSubmission must be active
        require(fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        // Contributor must not have already voted
        require(!fundingStorage.getMilestoneCompletionSubmissionHasVoted(_projectId, msg.sender), "This contributor address has already voted.");

        if (_approved) {
            uint currentApprovalCount = fundingStorage.getMilestoneCompletionSubmissionApprovalCount(_projectId);
            fundingStorage.setMilestoneCompletionSubmissionApprovalCount(_projectId, currentApprovalCount + 1);
        } else {
            uint currentDisapprovalCount = fundingStorage.getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
            fundingStorage.setMilestoneCompletionSubmissionDisapprovalCount(_projectId, currentDisapprovalCount + 1);
        }

        fundingStorage.setMilestoneCompletionSubmissionHasVoted(_projectId, msg.sender, true);
    }

    function finalizeMilestoneCompletion(uint _projectId) external onlyProjectDeveloper(_projectId) {
        // MilestoneCompletionSubmission must be active
        require(fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        if (hasPassedMilestoneCompletionVote(_projectId)) {
            succeedMilestoneCompletion(_projectId);
        } else {
            // Set milestone completion submission has failed
            fundingStorage.setMilestoneCompletionSubmissionHasFailed(_projectId, true);
        }
    }

    function hasPassedMilestoneCompletionVote(uint _projectId) private view returns (bool) {
        uint numContributors = fundingStorage.getProjectContributorListLength(_projectId);
        uint approvalCount = fundingStorage.getMilestoneCompletionSubmissionApprovalCount(_projectId);
        bool isTwoWeeksLater = getCurrentTime() >= fundingStorage.getMilestoneCompletionSubmissionTimestamp(_projectId) + 2 weeks;

        // Proposal needs >75% total approval, or for 2 days to have passed and >75% approval among voters
        require(((approvalCount > numContributors * 75 / 100) || isTwoWeeksLater),
            "Conditions for finalizing milestone completion have not yet been achieved.");

        uint disapprovalCount = fundingStorage.getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
        uint numVoters = approvalCount + disapprovalCount;
        uint votingThreshold = numVoters * 75 / 100;

        return (approvalCount > votingThreshold);
    }

    function succeedMilestoneCompletion(uint _projectId) private {
        uint activeIndex = fundingStorage.getActiveMilestoneIndex(_projectId);
        fundingStorage.setTimelineMilestoneIsComplete(_projectId, activeIndex, true);

        // Set milestone completion submission to inactive
        fundingStorage.setMilestoneCompletionSubmissionIsActive(_projectId, false);

        // Update completedMilestones, remove any pending milestones, and add the completed milestones + current active
        // milestone to the start of the pending timeline. This is to ensure that any future timeline proposals take
        // into account the milestones that have already released their funds.

        // Add current milestone to completed milestones list
        uint completedMilestonesLength = fundingStorage.getCompletedMilestonesLength(_projectId);

        ProjectStorageAccess.Milestone memory activeMilestone = fundingStorage.getTimelineMilestone(_projectId, activeIndex);

        fundingStorage.setCompletedMilestone(_projectId, completedMilestonesLength, activeMilestone.title, activeMilestone.description, activeMilestone.percentage, activeMilestone.isComplete);

        fundingStorage.setCompletedMilestonesLength(_projectId, completedMilestonesLength + 1);

        fundingStorage.moveCompletedMilestonesIntoPendingTimeline(_projectId);

        // Increment active milestone and release funds if this was not the last milestone
        if (activeIndex < fundingStorage.getTimelineLength(_projectId) - 1) {
            // Increment the active milestone
            fundingStorage.setActiveMilestoneIndex(_projectId, ++activeIndex);

            // Add currently active milestone to pendingTimeline
            ProjectStorageAccess.Milestone memory currentMilestone = fundingStorage.getTimelineMilestone(_projectId, activeIndex);
            completedMilestonesLength = fundingStorage.getCompletedMilestonesLength(_projectId);

            fundingStorage.setPendingTimelineMilestone(_projectId, completedMilestonesLength, currentMilestone.title, currentMilestone.description, currentMilestone.percentage, currentMilestone.isComplete);
            fundingStorage.setPendingTimelineLength(_projectId, completedMilestonesLength + 1);

            fundingStorage.releaseMilestoneFunds(_projectId, activeIndex);
        }
    }

    function getMilestoneCompletionSubmission(uint _projectId) external view returns (uint timestamp, uint approvalCount, uint disapprovalCount, string report, bool isActive, bool hasFailed) {
        ProjectStorageAccess.MilestoneCompletionSubmission memory submission = fundingStorage.getMilestoneCompletionSubmission(_projectId);

        return (submission.timestamp, submission.approvalCount, submission.disapprovalCount, submission.report, submission.isActive, submission.hasFailed);
    }
}
