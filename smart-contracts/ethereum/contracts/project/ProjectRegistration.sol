pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../libraries/project/ProjectHelpersLibrary.sol";
import "../libraries/storage/CurationStorageAccess.sol";

contract ProjectRegistration is ProjectBase {

    using ProjectHelpersLibrary for address;
    using CurationStorageAccess for address;

    event ProjectCreated(uint projectId);

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;
    }

    function createProject(
        string _title,
        string _description,
        string _about,
        uint _contributionGoal,
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
        fundingStorage.setProjectContributionGoal(projectId, _contributionGoal);
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
        uint _contributionGoal,
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
        fundingStorage.setProjectContributionGoal(_projectId, _contributionGoal);
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
            uint contributionGoal,
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
        contributionGoal = fundingStorage.getProjectContributionGoal(_projectId);
        developer = fundingStorage.getProjectDeveloper(_projectId);
        noRefunds = fundingStorage.getProjectNoRefunds(_projectId);
        noTimeline = fundingStorage.getProjectNoTimeline(_projectId);
        developerId = fundingStorage.getProjectDeveloperId(_projectId);

        return (id, status, title, description, about, contributionGoal, noRefunds, noTimeline, developer, developerId);
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
}
