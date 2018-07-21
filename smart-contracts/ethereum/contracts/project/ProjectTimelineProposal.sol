pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../libraries/project/ProjectHelpersLibrary.sol";

contract ProjectTimelineProposal is ProjectBase {

    using ProjectHelpersLibrary for address;

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;
    }

    function proposeNewTimeline(uint _projectId) external onlyProjectDeveloper(_projectId) onlyPublishedProject(_projectId) {
        // Can only suggest new timeline if there is not already a timeline proposal active
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "New timeline cannot be proposed if there is already an active timeline proposal.");
        // Can only suggest new timeline if there is not currently a vote on milestone completion
        require(!fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "New timeline cannot be proposed if there is an active vote on milestone completion.");

        fundingStorage.verifyPendingMilestones(_projectId);

        fundingStorage.setTimelineProposal(_projectId, now, 0, 0, true, false);
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

        fundingStorage.setTimelineProposalHasVoted(_projectId, msg.sender, true);
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
        bool isTwoWeeksLater = now >= fundingStorage.getTimelineProposalTimestamp(_projectId) + 2 weeks;

        // Proposal needs >75% total approval, or for 2 weeks to have passed and >75% approval among voters
        require(((approvalCount > numContributors * 75 / 100) || isTwoWeeksLater),
            "Conditions for finalizing timeline proposal have not yet been achieved.");

        uint disapprovalCount = fundingStorage.getTimelineProposalDisapprovalCount(_projectId);
        uint numVoters = approvalCount + disapprovalCount;
        uint votingThreshold = numVoters * 75 / 100;

        return (approvalCount > votingThreshold);
    }

    function succeedTimelineProposal(uint _projectId) private {
        // Push old timeline into timeline history
        fundingStorage.moveTimelineIntoTimelineHistory(_projectId);

        // Move pending timeline into timeline
        fundingStorage.movePendingMilestonesIntoTimeline(_projectId);

        // Set timeline proposal to inactive
        fundingStorage.setTimelineProposalIsActive(_projectId, false);
    }

    function getTimelineProposal(uint _projectId) external view returns (uint timestamp, uint approvalCount, uint disapprovalCount, bool isActive, bool hasFailed) {
        ProjectStorageAccess.TimelineProposal memory proposal = fundingStorage.getTimelineProposal(_projectId);

        return (proposal.timestamp, proposal.approvalCount, proposal.disapprovalCount, proposal.isActive, proposal.hasFailed);
    }
}
