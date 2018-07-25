pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../FundingVault.sol";
import "../libraries/ProjectMilestoneCompletionHelpersLibrary.sol";

contract ProjectMilestoneCompletion is ProjectBase {

    using ProjectMilestoneCompletionHelpersLibrary for address;
    using ContributionStorageAccess for address;

    modifier onlyProjectContributor(uint _projectId) {
        uint contributorId = fundingStorage.getContributorId(msg.sender);
        require(contributorId != 0, "This address is not a contributor.");
        require(fundingStorage.getContributesToProject(contributorId, _projectId), "This address is not a contributor to this project.");
        _;
    }

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = _fundingStorage;
    }

    function submitMilestoneCompletion(uint _projectId, string _report) external onlyProjectDeveloper(_projectId) onlyInDevelopmentProject(_projectId) {
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
            //fundingStorage.succeedMilestoneCompletion(_projectId);
        } else {
            // Set milestone completion submission to inactive
            fundingStorage.setMilestoneCompletionSubmissionIsActive(_projectId, false);

            // Set milestone completion submission has failed
            fundingStorage.setMilestoneCompletionSubmissionHasFailed(_projectId, true);

            fundingStorage.setProjectStatus(_projectId, uint(Status.Refundable));
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

    function getMilestoneCompletionSubmission(uint _projectId) external view returns (uint timestamp, uint approvalCount, uint disapprovalCount, string report, bool isActive, bool hasFailed) {
        ProjectStorageAccess.MilestoneCompletionSubmission memory submission = fundingStorage.getMilestoneCompletionSubmission(_projectId);

        return (submission.timestamp, submission.approvalCount, submission.disapprovalCount, submission.report, submission.isActive, submission.hasFailed);
    }
}
