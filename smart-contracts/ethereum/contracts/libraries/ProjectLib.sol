pragma solidity ^0.4.24;

import "../Project.sol";
import "../ProjectEternalStorage.sol";
import "./ProjectStorageAccess.sol";

library ProjectLib {

    using ProjectStorageAccess for address;

    function createProject(
        address _pStorage,
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
        uint id = _pStorage.getNextId();
        // Increment next ID
        _pStorage.incrementNextId();

        // Create project
        _pStorage.setProjectIsActive(id, true);
        _pStorage.setTitle(id, _title);
        _pStorage.setDescription(id, _description);
        _pStorage.setAbout(id, _about);
        _pStorage.setContributionGoal(id, _contributionGoal);
        _pStorage.setStatus(id, _status);
        _pStorage.setDeveloper(id, _developer);
        _pStorage.setDeveloperId(id, _developerId);

        return id;
    }

    function submitProjectForReview(address _pStorage, uint _projectId) public { // devRestricted(_developerId) {
        // check that project exists
        require(_pStorage.getProjectIsActive(_projectId), "Project does not exist.");

        verifyProjectMilestones(_pStorage, _projectId);

        verifyProjectTiers(_pStorage, _projectId);

        // Set project status to "Pending" and change timeline to active
        initializeTimeline(_pStorage, _projectId);
    }

    function verifyProjectMilestones(address _pStorage, uint _projectId) private view {
        // If project has a timeline, verify:
        // - Milestones are present
        // - Milestone percentages add up to 100
        if (!_pStorage.getNoTimeline(_projectId)) {
            uint timelineLength = _pStorage.getTimelineLength(_projectId);

            require(timelineLength > 0, "Project has no milestones.");

            uint percentageAcc = 0;
            for (uint i = 0; i < timelineLength; i++) {
                uint percentage = _pStorage.getTimelineMilestonePercentage(_projectId, i);
                percentageAcc = percentageAcc + percentage;
            }

            require(percentageAcc == 100, "Milestone percentages must add to 100.");
        }
    }

    function verifyProjectTiers(address _pStorage, uint _projectId) private view {
        // Verify that project has contribution tiers
        uint tiersLength = _pStorage.getContributionTiersLength(_projectId);
        require(tiersLength > 0, "Project has no contribution tiers.");
    }


    function initializeTimeline(address _pStorage, uint _projectId) private {
        // Check that there isn't already an active timeline
        require(!_pStorage.getTimelineIsActive(_projectId), "Timeline has already been initialized.");

        // Set timeline to active
        _pStorage.setTimelineIsActive(_projectId, true);

        // Set first milestone as active
        _pStorage.setActiveMilestoneIndex(_projectId, 0);

        // Change project status to "Pending"
        _pStorage.setStatus(_projectId, uint(Project.Status.Pending));
    }
}
