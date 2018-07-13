pragma solidity ^0.4.24;

import "./FundingStorage.sol";
import "./libraries/storage/ProjectStorageAccess.sol";
import "./libraries/storage/DeveloperStorageAccess.sol";
import "./libraries/storage/ContributionStorageAccess.sol";
import "./libraries/project/ProjectLib.sol";
import "./libraries/project/ProjectTimelineLib.sol";
import "./libraries/project/ProjectContributionTierLib.sol";
import "./libraries/project/ProjectTimelineProposalLib.sol";
import "./libraries/project/ProjectMilestoneCompletionLib.sol";

contract Project {

    using ProjectStorageAccess for address;
    using DeveloperStorageAccess for address;
    using ContributionStorageAccess for address;

    using ProjectLib for address;
    using ProjectTimelineLib for address;
    using ProjectContributionTierLib for address;
    using ProjectTimelineProposalLib for address;
    using ProjectMilestoneCompletionLib for address;

    enum Status {Draft, Pending, Published, Removed, Rejected}
    
    address fundingStorage;

    event ProjectCreated(uint projectId);

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;
    }

    function createProject(
        string _title,
        string _description,
        string _about,
        uint _contributionGoal
    )
        external
    {
        uint developerId = fundingStorage.getDeveloperId(msg.sender);
        require(developerId != 0, "This address is not a developer.");

        uint id = fundingStorage.createProject(_title, _description, _about, _contributionGoal, uint(Status.Draft), msg.sender, developerId);
        emit ProjectCreated(id);
    }

    function getProject(
        uint _projectId
    )
        external
        view
        returns (
            bool isActive,
            uint status,
            string title,
            string description,
            string about,
            uint contributionGoal,
            bool noRefunds,
            bool noTimeline,
            address developer,
            uint developerId
        )
    {
        isActive = fundingStorage.getProjectIsActive(_projectId);
        status = fundingStorage.getStatus(_projectId);
        title = fundingStorage.getTitle(_projectId);
        description = fundingStorage.getDescription(_projectId);
        about = fundingStorage.getAbout(_projectId);
        contributionGoal = fundingStorage.getContributionGoal(_projectId);
        developer = fundingStorage.getDeveloper(_projectId);
        noRefunds = fundingStorage.getNoRefunds(_projectId);
        noTimeline = fundingStorage.getNoTimeline(_projectId);
        developerId = fundingStorage.getDeveloperId(_projectId);

        return (isActive, status, title, description, about, contributionGoal, noRefunds, noTimeline, developer, developerId);
    }

    function getProjects() external view returns (uint[]) {
        uint numProjects = fundingStorage.getNextId();

        uint[] memory activeProjects = new uint[](numProjects);

        uint length = 0;
        for (uint i = 0; i < numProjects; i++) {
            if (fundingStorage.getProjectIsActive(i)) {
                activeProjects[length] = (i);
                length++;
            }
        }

        return activeProjects;
    }

    function addMilestone(
        uint _projectId,
        bool _isPending,
        string _title,
        string _description,
        uint _percentage
    )
        external
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");

        fundingStorage.addMilestone(_projectId, _isPending, _title, _description, _percentage);
    }

    function editMilestone(
        uint _projectId,
        bool _isPending,
        uint _index,
        string _title,
        string _description,
        uint _percentage
    )
        external
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");

        fundingStorage.editMilestone(_projectId, _isPending, _index, _title, _description, _percentage);
    }

    function clearPendingTimeline(uint _projectId) external {
        fundingStorage.clearPendingTimeline(_projectId);
    }

    function submitProjectForReview(uint _projectId) external {
        fundingStorage.submitProjectForReview(_projectId);
    }

    function proposeNewTimeline(uint _projectId) external {
        fundingStorage.proposeNewTimeline(_projectId);
    }

    function voteOnTimelineProposal(uint _projectId, bool _approved) external {
        fundingStorage.voteOnTimelineProposal(_projectId, _approved);
    }

    function finalizeTimelineProposal(uint _projectId) external {
        // TimelineProposal must be active
        require(fundingStorage.getTimelineProposalIsActive(_projectId), "There is no timeline proposal active.");

        if (hasPassedTimelineProposalVote(_projectId)) {
            fundingStorage.succeedTimelineProposal(_projectId);
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

    function submitMilestoneCompletion(uint _projectId, string _report) external {
        fundingStorage.submitMilestoneCompletion(_projectId, _report);
    }

    function voteOnMilestoneCompletion(uint _projectId, bool _approved) external {
        fundingStorage.voteOnMilestoneCompletion(_projectId, _approved);
    }

    function finalizeMilestoneCompletion(uint _projectId) external {
        // MilestoneCompletionSubmission must be active
        require(fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        if (hasPassedMilestoneCompletionVote(_projectId)) {
            fundingStorage.succeedMilestoneCompletion(_projectId);
        } else {
            // Set milestone completion submission has failed
            fundingStorage.setMilestoneCompletionSubmissionHasFailed(_projectId, true);
        }
    }

    function hasPassedMilestoneCompletionVote(uint _projectId) external view returns (bool) {
        uint numContributors = fundingStorage.getProjectContributorListLength(_projectId);
        uint approvalCount = fundingStorage.getMilestoneCompletionSubmissionApprovalCount(_projectId);
        uint disapprovalCount = fundingStorage.getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
        uint numVoters = approvalCount + disapprovalCount;
        bool isTwoWeeksLater = now >= fundingStorage.getMilestoneCompletionSubmissionTimestamp(_projectId) + 2 weeks;
        uint votingThreshold = numVoters * 75 / 100;

        // Proposal needs >75% total approval, or for 2 days to have passed and >75% approval among voters
        require((approvalCount > numContributors * 75 / 100) || isTwoWeeksLater,
            "Conditions for finalizing milestone completion have not yet been achieved.");

        return ((approvalCount > numContributors * 75 / 100) || (approvalCount > votingThreshold));
    }

    function addTier(
        uint _projectId,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
        external
    {
        fundingStorage.addTier(_projectId, _contributorLimit, _maxContribution, _minContribution, _rewards);
    }

    function editTier(
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
        external
    {
        fundingStorage.setPendingContributionTier(_projectId, _index, _contributorLimit, _maxContribution, _minContribution, _rewards);
    }

    function finalizeTiers(uint _projectId) external {
        fundingStorage.finalizeTiers(_projectId);
    }
}
