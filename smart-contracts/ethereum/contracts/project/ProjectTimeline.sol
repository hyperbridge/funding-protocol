pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";

contract ProjectTimeline is ProjectBase {

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;
    }

    function addMilestone(
        uint _projectId,
        string _title,
        string _description,
        uint _percentage
    )
        external
        onlyProjectDeveloper(_projectId)
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");
        require(!fundingStorage.getProjectNoTimeline(_projectId), "Cannot add a milestone to a project with no timeline.");
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "Pending milestones cannot be added while a timeline proposal vote is active.");

        // Get next available milestone index
        uint index = fundingStorage.getPendingTimelineLength(_projectId);

        fundingStorage.setPendingTimelineMilestone(_projectId, index, _title, _description, _percentage, false);

        // Increment pending timeline length
        fundingStorage.setPendingTimelineLength(_projectId, index + 1);
    }

    function editMilestone(
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage
    )
        external
        onlyProjectDeveloper(_projectId)
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "Pending milestones cannot be edited while a timeline proposal vote is active.");
        require(!fundingStorage.getPendingTimelineMilestoneIsComplete(_projectId, _index), "Cannot edit a completed milestone.");

        fundingStorage.setPendingTimelineMilestone(_projectId, _index, _title, _description, _percentage, false);
    }

    function getPendingTimelineMilestone(uint _projectId, uint _index) external view returns (string _title, string _description, uint _percentage, bool _isComplete) {
        ProjectStorageAccess.Milestone memory milestone = fundingStorage.getPendingTimelineMilestone(_projectId, _index);

        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function getTimelineMilestone(uint _projectId, uint _index) external view returns (string _title, string _description, uint _percentage, bool _isComplete) {
        ProjectStorageAccess.Milestone memory milestone = fundingStorage.getTimelineMilestone(_projectId, _index);

        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function getTimelineHistoryMilestone(uint _projectId, uint _timelineIndex, uint _milestoneIndex) external view returns (string _title, string _description, uint _percentage, bool _isComplete) {
        ProjectStorageAccess.Milestone memory milestone = fundingStorage.getTimelineHistoryMilestone(_projectId, _timelineIndex, _milestoneIndex);

        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function clearPendingTimeline(uint _projectId) external onlyProjectDeveloper(_projectId) {
        // There must not be an active timeline proposal
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "A timeline proposal vote is active.");

        fundingStorage.setPendingTimelineLength(_projectId, 0);

        uint completedMilestonesLength = fundingStorage.getCompletedMilestonesLength(_projectId);

        for (uint i = 0; i < completedMilestonesLength; i++) {
            ProjectStorageAccess.Milestone memory completedMilestone = fundingStorage.getCompletedMilestone(_projectId, i);
            fundingStorage.setPendingTimelineMilestone(
                _projectId,
                i,
                completedMilestone.title,
                completedMilestone.description,
                completedMilestone.percentage,
                completedMilestone.isComplete
            );
        }

        uint activeMilestoneIndex = fundingStorage.getActiveMilestoneIndex(_projectId);

        ProjectStorageAccess.Milestone memory activeMilestone = fundingStorage.getTimelineMilestone(_projectId, activeMilestoneIndex);
        fundingStorage.setPendingTimelineMilestone(
            _projectId,
            completedMilestonesLength,
            activeMilestone.title,
            activeMilestone.description,
            activeMilestone.percentage,
            activeMilestone.isComplete
        );

        fundingStorage.setPendingTimelineLength(_projectId, completedMilestonesLength + 1);
    }
}
