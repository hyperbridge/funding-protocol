pragma solidity ^0.4.24;

import "./FundingService.sol";
import "./ProjectEternalStorage.sol";
import "./libraries/ProjectStorageAccess.sol";
import "./libraries/ProjectLib.sol";
import "./libraries/ProjectTimelineLib.sol";
import "./libraries/ProjectContributionTierLib.sol";
import "./libraries/ProjectTimelineProposalLib.sol";
import "./libraries/ProjectMilestoneCompletionLib.sol";

contract Project {

    using ProjectStorageAccess for address;

    using ProjectLib for address;
    using ProjectTimelineLib for address;
    using ProjectContributionTierLib for address;
    using ProjectTimelineProposalLib for address;
    using ProjectMilestoneCompletionLib for address;

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

    modifier fundingServiceRestricted() {
        require(msg.sender == fundingService, "This action can only be performed by the Funding Service.");
        _;
    }

    address fundingService;
    address pStorage;

    constructor(address _fundingService) public {
        fundingService = _fundingService;
    }

    function registerProjectStorage(address _projectStorage) public {
        pStorage = _projectStorage;
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
    fundingServiceRestricted
    returns (uint)
    {
        uint id = pStorage.createProject(_title, _description, _about, _contributionGoal, uint(Status.Draft), _developer, _developerId);
        return id;
    }

    function getProject(uint _projectId) public view returns (bool isActive, uint status, string title, string description, string about, uint contributionGoal, address developer, uint developerId) {
        isActive = pStorage.getProjectIsActive(_projectId);
        status = pStorage.getStatus(_projectId);
        title = pStorage.getTitle(_projectId);
        description = pStorage.getDescription(_projectId);
        about = pStorage.getAbout(_projectId);
        contributionGoal = pStorage.getContributionGoal(_projectId);
        developer = pStorage.getDeveloper(_projectId);
        developerId = pStorage.getDeveloperId(_projectId);

        return (isActive, status, title, description, about, contributionGoal, developer, developerId);
    }

    function getProjects() public view returns (uint[]) {
        uint numProjects = pStorage.getNextId();

        uint[] memory activeProjects = new uint[](numProjects);

        uint length = 0;
        for (uint i = 0; i < numProjects; i++) {
            if (pStorage.getProjectIsActive(i)) {
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
    public
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");

        pStorage.addMilestone(_projectId, _isPending, _title, _description, _percentage);
    }

    function editMilestone(
        uint _projectId,
        bool _isPending,
        uint _index,
        string _title,
        string _description,
        uint _percentage
    )
    public
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");

        pStorage.editMilestone(_projectId, _isPending, _index, _title, _description, _percentage);
    }

    function clearPendingTimeline(uint _projectId) public {
        pStorage.clearPendingTimeline(_projectId);
    }

    function submitProjectForReview(uint _projectId) public { // devRestricted(_developerId) {
        pStorage.submitProjectForReview(_projectId);
    }

    function proposeNewTimeline(uint _projectId) public {
        pStorage.proposeNewTimeline(_projectId);
    }

    function voteOnTimelineProposal(uint _projectId, bool _approved) public {
        pStorage.voteOnTimelineProposal(_projectId, _approved);
    }

    function finalizeTimelineProposal(uint _projectId) public {
        // TimelineProposal must be active
        require(pStorage.getTimelineProposalIsActive(_projectId), "There is no timeline proposal active.");

        if (hasPassedTimelineProposalVote(_projectId)) {
            pStorage.succeedTimelineProposal(_projectId);
        } else {
            // Timeline proposal has failed
            pStorage.setTimelineProposalHasFailed(_projectId, true);
        }
    }

    function hasPassedTimelineProposalVote(uint _projectId) private view returns (bool) {
        FundingService fs = FundingService(fundingService);
        uint numContributors = fs.getProjectContributorList(_projectId).length;
        uint approvalCount = pStorage.getTimelineProposalApprovalCount(_projectId);
        uint disapprovalCount = pStorage.getTimelineProposalDisapprovalCount(_projectId);
        uint numVoters = approvalCount + disapprovalCount;
        bool isTwoWeeksLater = now >= pStorage.getTimelineProposalTimestamp(_projectId) + 2 weeks;
        uint votingThreshold = numVoters * 75 / 100;

        // Proposal needs >75% total approval, or for 2 weeks to have passed and >75% approval among voters
        require(((approvalCount > numContributors * 75 / 100) || isTwoWeeksLater),
            "Conditions for finalizing timeline proposal have not yet been achieved.");

        return ((approvalCount > numContributors * 75 / 100) || (approvalCount > votingThreshold));
    }

    function submitMilestoneCompletion(uint _projectId, string _report) public {
        pStorage.submitMilestoneCompletion(_projectId, _report);
    }

    function voteOnMilestoneCompletion(uint _projectId, bool _approved) public {
        pStorage.voteOnMilestoneCompletion(_projectId, _approved);
    }

    function finalizeMilestoneCompletion(uint _projectId) public {
        // MilestoneCompletionSubmission must be active
        require(pStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        if (hasPassedMilestoneCompletionVote(_projectId)) {
            pStorage.succeedMilestoneCompletion(_projectId);
        } else {
            // Set milestone completion submission has failed
            pStorage.setMilestoneCompletionSubmissionHasFailed(_projectId, true);
        }
    }

    function hasPassedMilestoneCompletionVote(uint _projectId) private view returns (bool) {
        FundingService fs = FundingService(fundingService);
        uint numContributors = fs.getProjectContributorList(_projectId).length;
        uint approvalCount = pStorage.getMilestoneCompletionSubmissionApprovalCount(_projectId);
        uint disapprovalCount = pStorage.getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
        uint numVoters = approvalCount + disapprovalCount;
        bool isTwoWeeksLater = now >= pStorage.getMilestoneCompletionSubmissionTimestamp(_projectId) + 2 weeks;
        uint votingThreshold = numVoters * 75 / 100;

        // Proposal needs >75% total approval, or for 2 days to have passed and >75% approval among voters
        require((approvalCount > numContributors * 75 / 100) || isTwoWeeksLater,
            "Conditions for finalizing milestone completion have not yet been achieved.");

        return ((approvalCount > numContributors * 75 / 100) || (approvalCount > votingThreshold));
    }

    function addTier(uint _projectId, uint _contributorLimit, uint _maxContribution, uint _minContribution, string _rewards) public {
        pStorage.addTier(_projectId, _contributorLimit, _maxContribution, _minContribution, _rewards);
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
        pStorage.setPendingContributionTier(_projectId, _index, _contributorLimit, _maxContribution, _minContribution, _rewards);
    }

    function finalizeTiers(uint _projectId) public {
        pStorage.finalizeTiers(_projectId);
    }
}
