pragma solidity ^0.4.24;

import "../storage/ProjectStorageAccess.sol";
import "../../Project.sol";

library ProjectLib {

    using ProjectStorageAccess for address;

    function createProject(
        address _fundingStorage,
        string _title,
        string _description,
        string _about,
        uint _contributionGoal,
        uint _status,
        address _developer,
        uint _developerId
    )
    external
    returns (uint)
    {
        // Get next ID from storage
        uint id = _fundingStorage.getNextId();
        // Increment next ID
        _fundingStorage.incrementNextId();

        // Create project
        _fundingStorage.setProjectIsActive(id, true);
        _fundingStorage.setTitle(id, _title);
        _fundingStorage.setDescription(id, _description);
        _fundingStorage.setAbout(id, _about);
        _fundingStorage.setContributionGoal(id, _contributionGoal);
        _fundingStorage.setStatus(id, _status);
        _fundingStorage.setDeveloper(id, _developer);
        _fundingStorage.setDeveloperId(id, _developerId);

        return id;
    }

    function submitProjectForReview(address _fundingStorage, uint _projectId) external {
        // check that project exists
        require(_fundingStorage.getProjectIsActive(_projectId), "Project does not exist.");

        verifyProjectMilestones(_fundingStorage, _projectId);

        verifyProjectTiers(_fundingStorage, _projectId);

        // Set project status to "Pending" and change timeline to active
        initializeTimeline(_fundingStorage, _projectId);
    }

    function verifyProjectMilestones(address _fundingStorage, uint _projectId) private view {
        // If project has a timeline, verify:
        // - Milestones are present
        // - Milestone percentages add up to 100
        if (!_fundingStorage.getNoTimeline(_projectId)) {
            uint timelineLength = _fundingStorage.getTimelineLength(_projectId);

            require(timelineLength > 0, "Project has no milestones.");

            uint percentageAcc = 0;
            for (uint i = 0; i < timelineLength; i++) {
                uint percentage = _fundingStorage.getTimelineMilestonePercentage(_projectId, i);
                percentageAcc = percentageAcc + percentage;
            }

            require(percentageAcc == 100, "Milestone percentages must add to 100.");
        }
    }

    function verifyProjectTiers(address _fundingStorage, uint _projectId) private view {
        // Verify that project has contribution tiers
        uint tiersLength = _fundingStorage.getContributionTiersLength(_projectId);
        require(tiersLength > 0, "Project has no contribution tiers.");
    }


    function initializeTimeline(address _fundingStorage, uint _projectId) private {
        // Check that there isn't already an active timeline
        require(!_fundingStorage.getTimelineIsActive(_projectId), "Timeline has already been initialized.");

        // Set timeline to active
        _fundingStorage.setTimelineIsActive(_projectId, true);

        // Set first milestone as active
        _fundingStorage.setActiveMilestoneIndex(_projectId, 0);

        // Change project status to "Pending"
        _fundingStorage.setStatus(_projectId, uint(Project.Status.Pending));
    }
}
