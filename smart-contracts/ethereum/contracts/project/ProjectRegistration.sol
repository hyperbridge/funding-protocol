pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../libraries/storage/CurationStorageAccess.sol";
import "../libraries/ProjectTimelineHelpersLibrary.sol";
import "../libraries/ProjectContributionTierHelpersLibrary.sol";

contract ProjectRegistration is ProjectBase {

    using ProjectTimelineHelpersLibrary for address;
    using ProjectContributionTierHelpersLibrary for address;
    using CurationStorageAccess for address;

    event ProjectCreated(uint projectId);

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;
    }

    function initialize() external {
        require(FundingStorage(fundingStorage).getContractIsValid(this), "This contract is not registered in FundingStorage.");

        // reserve projectId 0
        fundingStorage.incrementNextProjectId();
    }

    function createProject(
        string _title,
        string _description,
        string _about,
        uint _minContributionGoal,
        uint _maxContributionGoal,
        uint _contributionPeriod,
        bool _noRefunds,
        bool _noTimeline
    )
        external
    {
        // Verify that sender is a developer
        uint developerId = fundingStorage.getDeveloperId(msg.sender);
        require(developerId != 0, "This address is not a developer.");

        // Get next ID from storage + increment next ID
        uint projectId = fundingStorage.generateNewProjectId();

        // Set new project attributes
        fundingStorage.setProjectStatus(projectId, uint(Status.Draft));
        fundingStorage.setProjectTitle(projectId, _title);
        fundingStorage.setProjectDescription(projectId, _description);
        fundingStorage.setProjectAbout(projectId, _about);
        fundingStorage.setProjectMinContributionGoal(projectId, _minContributionGoal);
        fundingStorage.setProjectMaxContributionGoal(projectId, _maxContributionGoal);
        fundingStorage.setProjectContributionPeriod(projectId, _contributionPeriod);
        fundingStorage.setProjectNoRefunds(projectId, _noRefunds);
        fundingStorage.setProjectNoTimeline(projectId, _noTimeline);
        fundingStorage.setProjectDeveloper(projectId, msg.sender);
        fundingStorage.setProjectDeveloperId(projectId, developerId);

        emit ProjectCreated(projectId);
    }

    function editProject(
        uint _projectId,
        string _title,
        string _description,
        string _about,
        uint _minContributionGoal,
        uint _maxContributionGoal,
        uint _contributionPeriod,
        bool _noRefunds,
        bool _noTimeline
    )
        external
        onlyProjectDeveloper(_projectId)
        onlyDraftProject(_projectId)
    {
        // Set project attributes
        fundingStorage.setProjectTitle(_projectId, _title);
        fundingStorage.setProjectDescription(_projectId, _description);
        fundingStorage.setProjectAbout(_projectId, _about);
        fundingStorage.setProjectMinContributionGoal(_projectId, _minContributionGoal);
        fundingStorage.setProjectMaxContributionGoal(_projectId, _maxContributionGoal);
        fundingStorage.setProjectContributionPeriod(_projectId, _contributionPeriod);
        fundingStorage.setProjectNoRefunds(_projectId, _noRefunds);
        fundingStorage.setProjectNoTimeline(_projectId, _noTimeline);
    }

    function getProject(
        uint _projectId
    )
        external
        view
        returns (
            uint id,
            uint status,
            string title,
            string description,
            string about,
            uint minContributionGoal,
            uint maxContributionGoal,
            uint contributionPeriod,
            bool noRefunds,
            bool noTimeline,
            address developer,
            uint developerId
        )
    {
        id = _projectId;
        status = fundingStorage.getProjectStatus(_projectId);
        title = fundingStorage.getProjectTitle(_projectId);
        description = fundingStorage.getProjectDescription(_projectId);
        about = fundingStorage.getProjectAbout(_projectId);
        minContributionGoal = fundingStorage.getProjectMinContributionGoal(_projectId);
        maxContributionGoal = fundingStorage.getProjectMaxContributionGoal(_projectId);
        contributionPeriod = fundingStorage.getProjectContributionPeriod(_projectId);
        developer = fundingStorage.getProjectDeveloper(_projectId);
        noRefunds = fundingStorage.getProjectNoRefunds(_projectId);
        noTimeline = fundingStorage.getProjectNoTimeline(_projectId);
        developerId = fundingStorage.getProjectDeveloperId(_projectId);

        return (id, status, title, description, about, minContributionGoal, maxContributionGoal, contributionPeriod, noRefunds, noTimeline, developer, developerId);
    }

    function submitProjectForReview(uint _projectId) external onlyProjectDeveloper(_projectId) onlyDraftProject(_projectId) {
        bool noTimeline = fundingStorage.getProjectNoTimeline(_projectId);

        // Make sure project has outlined contribution tiers
        verifyProjectTiers(_projectId);

        // If project has a timeline, verify that milestone percentages add up to 100% and set active timeline
        if (!noTimeline) {
            fundingStorage.verifyPendingMilestones(_projectId);
            fundingStorage.movePendingMilestonesIntoTimeline(_projectId);
            fundingStorage.movePendingContributionTiersIntoActiveContributionTiers(_projectId);
        }

        // Change project status to "Pending"
        fundingStorage.setProjectStatus(_projectId, uint(Status.Pending));

        // Open curation
        fundingStorage.setDraftCurationTimestamp(_projectId, now);
        fundingStorage.setDraftCurationIsActive(_projectId, true);
    }

    function verifyProjectTiers(uint _projectId) private view {
        // Verify that project has contribution tiers
        uint tiersLength = fundingStorage.getPendingContributionTiersLength(_projectId);
        require(tiersLength > 0, "Project has no contribution tiers.");
    }

    function beginProjectDevelopment(uint _projectId) external onlyProjectDeveloper(_projectId) {
        require(fundingStorage.getProjectStatus(_projectId) == uint(Status.Contributable), "This project is not currently accepting contributions.");

        uint fundsRaised = fundingStorage.getProjectFundsRaised(_projectId);
        uint minGoal = fundingStorage.getProjectMinContributionGoal(_projectId);

        if (fundsRaised >= minGoal) {
            fundingStorage.setProjectStatus(_projectId, uint(Status.InDevelopment));
            fundingStorage.releaseMilestoneFunds(_projectId, 0);
        } else {
            fundingStorage.setProjectStatus(_projectId, uint(Status.Refundable));
        }
    }
}
