pragma solidity ^0.4.24;

import "../Project.sol";
import "../FundingStorage.sol";
import "./ProjectStorageAccess.sol";

library ProjectTimelineLib {

    using ProjectStorageAccess for address;

    function addMilestone(
        address _pStorage,
        uint _projectId,
        bool _isPending,
        string _title,
        string _description,
        uint _percentage
    )
    external
    {
        require(!_pStorage.getNoTimeline(_projectId), "Cannot add a milestone to a project with no timeline.");

        if (_isPending) {
            require(!_pStorage.getTimelineProposalIsActive(_projectId), "Pending milestones cannot be added while a timeline proposal vote is active.");
            require(_pStorage.getTimelineIsActive(_projectId), "Pending milestones cannot be added when there is not a timeline currently active.");

            // Get next available milestone index
            uint index = _pStorage.getPendingTimelineLength(_projectId);

            _pStorage.setPendingTimelineMilestone(_projectId, index, _title, _description, _percentage, false);

            // Increment pending timeline length
            _pStorage.setPendingTimelineLength(_projectId, index + 1);
        } else {
            require(!_pStorage.getTimelineIsActive(_projectId), "Milestone cannot be added to an active timeline.");

            // get next available milestone index
            index = _pStorage.getTimelineLength(_projectId);

            _pStorage.setTimelineMilestone(_projectId, index, _title, _description, _percentage, false);

            // Increment timeline length
            _pStorage.setTimelineLength(_projectId, index + 1);
        }
    }

    function editMilestone(
        address _pStorage,
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
            require(!_pStorage.getTimelineProposalIsActive(_projectId), "Pending milestones cannot be edited while a timeline proposal vote is active.");
            require(!_pStorage.getPendingTimelineMilestoneIsComplete(_projectId, _index), "Cannot edit a completed milestone.");

            _pStorage.setPendingTimelineMilestone(_projectId, _index, _title, _description, _percentage, false);
        } else {
            require(!_pStorage.getTimelineIsActive(_projectId), "Milestones in an active timeline cannot be edited.");
            require(!_pStorage.getTimelineMilestoneIsComplete(_projectId, _index), "Cannot edit a completed milestone.");

            _pStorage.setTimelineMilestone(_projectId, _index, _title, _description, _percentage, false);
        }
    }

    function clearPendingTimeline(address _pStorage, uint _projectId) external {
        // There must not be an active timeline proposal
        require(!_pStorage.getTimelineProposalIsActive(_projectId), "A timeline proposal vote is active.");

        _pStorage.deletePendingTimeline(_projectId);

        uint completedMilestonesLength = _pStorage.getCompletedMilestonesLength(_projectId);

        for (uint i = 0; i < completedMilestonesLength; i++) {
            ProjectStorageAccess.Milestone memory completedMilestone = _pStorage._getCompletedMilestone(_projectId, i);
            _pStorage.setPendingTimelineMilestone(
                _projectId,
                i,
                completedMilestone.title,
                completedMilestone.description,
                completedMilestone.percentage,
                completedMilestone.isComplete
            );
        }

        uint activeMilestoneIndex = _pStorage.getActiveMilestoneIndex(_projectId);

        ProjectStorageAccess.Milestone memory activeMilestone = _pStorage._getTimelineMilestone(_projectId, activeMilestoneIndex);
        _pStorage.setPendingTimelineMilestone(
            _projectId,
            completedMilestonesLength,
            activeMilestone.title,
            activeMilestone.description,
            activeMilestone.percentage,
            activeMilestone.isComplete
        );

        _pStorage.setPendingTimelineLength(_projectId, completedMilestonesLength + 1);
    }

    function initializeTimeline(address _pStorage, uint _projectId) external {
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
