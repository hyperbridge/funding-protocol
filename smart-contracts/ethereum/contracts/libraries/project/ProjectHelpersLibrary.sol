pragma solidity ^0.4.24;

import "../storage/ProjectStorageAccess.sol";

library ProjectHelpersLibrary {

    using ProjectStorageAccess for address;

    function moveTimelineIntoTimelineHistory(address _fundingStorage, uint _projectId) external {
        uint historyLength = _fundingStorage.getTimelineHistoryLength(_projectId);
        uint timelineLength = _fundingStorage.getTimelineLength(_projectId);

        for (uint i = 0; i < timelineLength; i++) {
            ProjectStorageAccess.Milestone memory milestone = _fundingStorage.getTimelineMilestone(_projectId, i);
            _fundingStorage.setTimelineHistoryMilestoneTitle(_projectId, historyLength, i, milestone.title);
            _fundingStorage.setTimelineHistoryMilestoneDescription(_projectId, historyLength, i, milestone.description);
            _fundingStorage.setTimelineHistoryMilestonePercentage(_projectId, historyLength, i, milestone.percentage);
            _fundingStorage.setTimelineHistoryMilestoneIsComplete(_projectId, historyLength, i, milestone.isComplete);
        }

        _fundingStorage.setTimelineHistoryLength(_projectId, historyLength + 1);
        _fundingStorage.setTimelineHistoryMilestonesLength(_projectId, historyLength, timelineLength);
        _fundingStorage.setTimelineLength(_projectId, 0);
    }

    function movePendingMilestonesIntoTimeline(address _fundingStorage, uint _projectId) external {
        uint pendingTimelineLength = _fundingStorage.getPendingTimelineLength(_projectId);

        for (uint j = 0; j < pendingTimelineLength; j++) {
            ProjectStorageAccess.Milestone memory pendingMilestone = _fundingStorage.getPendingTimelineMilestone(_projectId, j);
            _fundingStorage.setTimelineMilestone(_projectId, j, pendingMilestone.title, pendingMilestone.description, pendingMilestone.percentage, pendingMilestone.isComplete);
        }

        _fundingStorage.setTimelineLength(_projectId, pendingTimelineLength);
        _fundingStorage.setPendingTimelineLength(_projectId, 0);
    }

    function movePendingContributionTiersIntoActiveContributionTiers(address _fundingStorage, uint _projectId) external {
        uint length = _fundingStorage.getPendingContributionTiersLength(_projectId);

        for (uint i = 0; i < length; i++) {
            ProjectStorageAccess.ContributionTier memory tier = _fundingStorage.getPendingContributionTier(_projectId, i);

            _fundingStorage.setContributionTier(_projectId, i, tier.contributorLimit, tier.minContribution, tier.maxContribution, tier.rewards);
        }

        _fundingStorage.setContributionTiersLength(_projectId, length);
        _fundingStorage.setPendingContributionTiersLength(_projectId, 0);
    }
}
