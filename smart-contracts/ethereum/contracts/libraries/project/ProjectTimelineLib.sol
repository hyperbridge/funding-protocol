pragma solidity ^0.4.24;

import "../storage/ProjectStorageAccess.sol";
import "../../Project.sol";

library ProjectTimelineLib {

    using ProjectStorageAccess for address;

    function addMilestone(
        address _fundingStorage,
        uint _projectId,
        bool _isPending,
        string _title,
        string _description,
        uint _percentage
    )
    external
    {
        require(!_fundingStorage.getProjectNoTimeline(_projectId), "Cannot add a milestone to a project with no timeline.");

        if (_isPending) {
            require(!_fundingStorage.getTimelineProposalIsActive(_projectId), "Pending milestones cannot be added while a timeline proposal vote is active.");
            require(_fundingStorage.getTimelineIsActive(_projectId), "Pending milestones cannot be added when there is not a timeline currently active.");

            // Get next available milestone index
            uint index = _fundingStorage.getPendingTimelineLength(_projectId);

            _fundingStorage.setPendingTimelineMilestone(_projectId, index, _title, _description, _percentage, false);

            // Increment pending timeline length
            _fundingStorage.setPendingTimelineLength(_projectId, index + 1);
        } else {
            require(!_fundingStorage.getTimelineIsActive(_projectId), "Milestone cannot be added to an active timeline.");

            // get next available milestone index
            index = _fundingStorage.getTimelineLength(_projectId);

            _fundingStorage.setTimelineMilestone(_projectId, index, _title, _description, _percentage, false);

            // Increment timeline length
            _fundingStorage.setTimelineLength(_projectId, index + 1);
        }
    }

    function editMilestone(
        address _fundingStorage,
        uint _projectId,
        bool _isPending,
        uint _index,
        string _title,
        string _description,
        uint _percentage
    )
    external
    {
        if (_isPending) {
            require(!_fundingStorage.getTimelineProposalIsActive(_projectId), "Pending milestones cannot be edited while a timeline proposal vote is active.");
            require(!_fundingStorage.getPendingTimelineMilestoneIsComplete(_projectId, _index), "Cannot edit a completed milestone.");

            _fundingStorage.setPendingTimelineMilestone(_projectId, _index, _title, _description, _percentage, false);
        } else {
            require(!_fundingStorage.getTimelineIsActive(_projectId), "Milestones in an active timeline cannot be edited.");
            require(!_fundingStorage.getTimelineMilestoneIsComplete(_projectId, _index), "Cannot edit a completed milestone.");

            _fundingStorage.setTimelineMilestone(_projectId, _index, _title, _description, _percentage, false);
        }
    }

    function clearPendingTimeline(address _fundingStorage, uint _projectId) external {
        // There must not be an active timeline proposal
        require(!_fundingStorage.getTimelineProposalIsActive(_projectId), "A timeline proposal vote is active.");

        _fundingStorage.deletePendingTimeline(_projectId);

        uint completedMilestonesLength = _fundingStorage.getCompletedMilestonesLength(_projectId);

        for (uint i = 0; i < completedMilestonesLength; i++) {
            ProjectStorageAccess.Milestone memory completedMilestone = _fundingStorage.getCompletedMilestone(_projectId, i);
            _fundingStorage.setPendingTimelineMilestone(
                _projectId,
                i,
                completedMilestone.title,
                completedMilestone.description,
                completedMilestone.percentage,
                completedMilestone.isComplete
            );
        }

        uint activeMilestoneIndex = _fundingStorage.getActiveMilestoneIndex(_projectId);

        ProjectStorageAccess.Milestone memory activeMilestone = _fundingStorage.getTimelineMilestone(_projectId, activeMilestoneIndex);
        _fundingStorage.setPendingTimelineMilestone(
            _projectId,
            completedMilestonesLength,
            activeMilestone.title,
            activeMilestone.description,
            activeMilestone.percentage,
            activeMilestone.isComplete
        );

        _fundingStorage.setPendingTimelineLength(_projectId, completedMilestonesLength + 1);
    }

    function initializeTimeline(address _fundingStorage, uint _projectId) external {
        // Check that there isn't already an active timeline
        require(!_fundingStorage.getTimelineIsActive(_projectId), "Timeline has already been initialized.");

        // Set timeline to active
        _fundingStorage.setTimelineIsActive(_projectId, true);

        // Set first milestone as active
        _fundingStorage.setActiveMilestoneIndex(_projectId, 0);

        // Change project status to "Pending"
        _fundingStorage.setProjectStatus(_projectId, uint(Project.Status.Pending));
    }
}
