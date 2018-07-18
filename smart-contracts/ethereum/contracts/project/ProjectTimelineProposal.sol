pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../libraries/project/ProjectHelpersLibrary.sol";

contract ProjectTimelineProposal is ProjectBase {

    using ProjectHelpersLibrary for address;

    constructor(address fundingStorage) public {
        fundingStorage = fundingStorage;
    }

    function proposeNewTimeline(uint _projectId) external onlyProjectDeveloper(_projectId) {
        // Can only suggest new timeline if one already exists
        require(fundingStorage.getTimelineIsActive(_projectId), "New timeline cannot be proposed if there is no current active timeline.");
        // Can only suggest new timeline if there is not currently a vote on milestone completion
        require(!fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "New timeline cannot be proposed if there is an active vote on milestone completion.");

        verifyPendingTimelinePercentages(_projectId);

        fundingStorage.setTimelineProposalTimestamp(_projectId, now);
        fundingStorage.setTimelineProposalIsActive(_projectId, true);
    }

    function verifyPendingTimelinePercentages(uint _projectId) private view {
        // If project has a timeline, verify:
        // - Milestones are present
        // - Milestone percentages add up to 100
        if (!fundingStorage.getProjectNoTimeline(_projectId)) {
            uint pendingTimelineLength = fundingStorage.getPendingTimelineLength(_projectId);
            require(pendingTimelineLength > 0, "Pending timeline is empty.");

            uint percentageAcc = 0;
            for (uint i = 0; i < pendingTimelineLength; i++) {
                percentageAcc += fundingStorage.getPendingTimelineMilestonePercentage(_projectId, i);
            }

            require(percentageAcc == 100, "Milestone percentages must add to 100.");
        }
    }

    function voteOnTimelineProposal(uint _projectId, bool _approved) external onlyProjectContributor(_projectId) {
        // TimelineProposal must be active
        require(fundingStorage.getTimelineProposalIsActive(_projectId), "No timeline proposal active.");

        // Contributor must not have already voted
        require(!fundingStorage.getTimelineProposalHasVoted(_projectId, msg.sender), "This contributor address has already voted.");

        if (_approved) {
            uint currentApprovalCount = fundingStorage.getTimelineProposalApprovalCount(_projectId);
            fundingStorage.setTimelineProposalApprovalCount(_projectId, currentApprovalCount + 1);
        } else {
            uint currentDisapprovalCount = fundingStorage.getTimelineProposalDisapprovalCount(_projectId);
            fundingStorage.setTimelineProposalDisapprovalCount(_projectId, currentDisapprovalCount + 1);
        }

        fundingStorage.setTimelineProposalIsActive(_projectId, true);    
    }

    function finalizeTimelineProposal(uint _projectId) external onlyProjectDeveloper(_projectId) {
        // TimelineProposal must be active
        require(fundingStorage.getTimelineProposalIsActive(_projectId), "There is no timeline proposal active.");

        if (hasPassedTimelineProposalVote(_projectId)) {
            succeedTimelineProposal(_projectId);
        } else {
            // Timeline proposal has failed
            fundingStorage.setTimelineProposalHasFailed(_projectId, true);
        }
    }

    function hasPassedTimelineProposalVote(uint _projectId) private view returns (bool) {
        uint numContributors = fundingStorage.getProjectContributorListLength(_projectId);
        uint approvalCount = fundingStorage.getTimelineProposalApprovalCount(_projectId);
        uint disapprovalCount = fundingStorage.getTimelineProposalDisapprovalCount(_projectId);
        uint numVoters = approvalCount + disapprovalCount;
        bool isTwoWeeksLater = now >= fundingStorage.getTimelineProposalTimestamp(_projectId) + 2 weeks;
        uint votingThreshold = numVoters * 75 / 100;

        // Proposal needs >75% total approval, or for 2 weeks to have passed and >75% approval among voters
        require(((approvalCount > numContributors * 75 / 100) || isTwoWeeksLater),
            "Conditions for finalizing timeline proposal have not yet been achieved.");

        return ((approvalCount > numContributors * 75 / 100) || (approvalCount > votingThreshold));
    }

    function succeedTimelineProposal(uint _projectId) private {
        // Set current timeline to inactive
        fundingStorage.setTimelineIsActive(_projectId, false);

        // Push old timeline into timeline history
        fundingStorage.moveTimelineIntoTimelineHistory(_projectId);

        // Move pending timeline into timeline
        fundingStorage.movePendingMilestonesIntoTimeline(_projectId);

        // Set timeline to be active
        fundingStorage.setTimelineIsActive(_projectId, true);

        // Set timeline proposal to inactive
        fundingStorage.setTimelineProposalIsActive(_projectId, false);
    }
}
