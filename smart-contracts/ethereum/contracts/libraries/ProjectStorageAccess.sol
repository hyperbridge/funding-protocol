pragma solidity ^0.4.24;

import "./ProjectEternalStorageLib.sol";

library ProjectStorageAccess {

    using ProjectEternalStorageLib for ProjectEternalStorage.ProjectStorage;

    struct Timeline {
        Milestone[] milestones;
        bool isActive;
    }

    struct Milestone {
        string title;
        string description;
        uint percentage;
        bool isComplete;
    }

    struct ContributionTier {
        uint contributorLimit;
        uint minContribution;
        uint maxContribution;
        string rewards;
    }

    struct TimelineProposal {
        uint timestamp;
        uint approvalCount;
        uint disapprovalCount;
        bool isActive;
        bool hasFailed;
        mapping(address => bool) voters;
    }

    struct MilestoneCompletionSubmission {
        uint timestamp;
        uint approvalCount;
        uint disapprovalCount;
        string report;
        bool isActive;
        bool hasFailed;
        mapping(address => bool) voters;
    }

    /*
        Each project stores the following data in ProjectStorage and accesses it through the associated namespace:
            uint id                                                         (project.id)
            Status status                                                   (project.status)
            string title                                                    (project.title)
            string description                                              (project.description)
            string about                                                    (project.about)
            address developer                                               (project.developer)
            uint developerId                                                (project.developerId)
            uint contributionGoal                                           (project.contributionGoal)
            ContributionTier[] contributionTiers
                uint contributorLimit                                       (project.contributionTiers.contributorLimit)
                uint minContribution                                        (project.contributionTiers.minContribution)
                uint maxContribution                                        (project.contributionTiers.maxContribution)
                uint rewards                                                (project.contributionTiers.rewards)
            ContributionTier[] pendingContributionTiers
                uint contributorLimit                                       (project.pendingContributionTiers.contributorLimit)
                uint minContribution                                        (project.pendingContributionTiers.minContribution)
                uint maxContribution                                        (project.pendingContributionTiers.maxContribution)
                string rewards                                              (project.pendingContributionTiers.rewards)
            bool noRefunds                                                  (project.noRefunds)
            bool noTimeline                                                 (project.noTimeline)
            Timeline timeline
                bool isActive                                               (project.timeline.isActive)
                Milestone[] milestones
                    Milestone
                        string title                                        (project.timeline.milestones.title)
                        string description                                  (project.timeline.milestones.description)
                        uint percentage                                     (project.timeline.milestones.percentage)
                        bool isComplete                                     (project.timeline.milestones.isComplete)
            uint activeMilestoneIndex                                       (project.activeMilestoneIndex)
            Timeline pendingTimeline
                bool isActive                                               (project.pendingTimeline.isActive)
                Milestone[] milestones
                    Milestone
                        string title                                        (project.pendingTimeline.milestones.title)
                        string description                                  (project.pendingTimeline.milestones.description)
                        uint percentage                                     (project.pendingTimeline.milestones.percentage)
                        bool isComplete                                     (project.pendingTimeline.milestones.isComplete)
            Milestone[] completedMilestones
                Milestone
                    string title                                            (project.completedMilestones.title)
                    string description                                      (project.completedMilestones.description)
                    uint percentage                                         (project.completedMilestones.percentage)
                    bool isComplete                                         (project.completedMilestones.isComplete)
            Timeline[] timelineHistory
                Timeline
                    Milestone[]
                        Milestone
                            string title                                    (project.timelineHistory.milestones.title)
                            string description                              (project.timelineHistory.milestones.description)
                            uint percentage                                 (project.timelineHistory.milestones.percentage)
                            bool isComplete                                 (project.timelineHistory.milestones.isComplete)
            TimelineProposal timelineProposal
                uint timestamp                                              (project.timelineProposal.timestamp)
                uint approvalCount                                          (project.timelineProposal.approvalCount)
                uint disapprovalCount                                       (project.timelineProposal.disapprovalCount)
                bool isActive                                               (project.timelineProposal.isActive)
                bool hasFailed                                              (project.timelineProposal.hasFailed)
                mapping(address => bool) voters                             (project.timelineProposal.voters)
            MilestoneCompletionSubmission milestoneCompletionSubmission
                uint timestamp                                              (project.milestoneCompletionSubmission.timestamp)
                uint approvalCount                                          (project.milestoneCompletionSubmission.approvalCount)
                uint disapprovalCount                                       (project.milestoneCompletionSubmission.disapprovalCount)
                string report                                               (project.milestoneCompletionSubmission.report)
                bool isActive                                               (project.milestoneCompletionSubmission.isActive)
                bool hasFailed                                              (project.milestoneCompletionSubmission.hasFailed)
                mapping(address => bool) voters                             (project.milestoneCompletionSubmission.voters)
    */

    // Getters

    function getNextId(ProjectEternalStorage.ProjectStorage storage _pStorage) internal view returns (uint) {
        return _pStorage.getUint(keccak256("project.nextId"));
    }

    function getProjectIsActive(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.activeProjects", _projectId)));
    }

    function getStatus(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.status", _projectId)));
    }

    function getTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (string) {
        return _pStorage.getString(keccak256(abi.encodePacked("project.title", _projectId)));
    }

    function getDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (string) {
        return _pStorage.getString(keccak256(abi.encodePacked("project.description", _projectId)));
    }

    function getAbout(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (string) {
        return _pStorage.getString(keccak256(abi.encodePacked("project.title", _projectId)));
    }

    function getDeveloper(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (address) {
        return _pStorage.getAddress(keccak256(abi.encodePacked("project.developer", _projectId)));
    }

    function getDeveloperId(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.developerId", _projectId)));
    }

    function getContributionGoal(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)));
    }

    function getNoRefunds(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)));
    }

    function getNoTimeline(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)));
    }

    function getActiveMilestoneIndex(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)));
    }

    // Timeline

    function getTimelineIsActive(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.timeline.isActive", _projectId)));
    }

    function getTimelineLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)));
    }

    function getPendingTimelineLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)));
    }

    function getTimelineHistoryLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)));
    }

    // Milestone

    function getTimelineMilestoneTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
    }

    function getTimelineMilestoneDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
    }

    function getTimelineMilestonePercentage(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
    }

    function getTimelineMilestoneIsComplete(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));
    }

    function getTimelineMilestone(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string memory title, string memory description, uint percentage, bool isComplete) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        title = _pStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
        description = _pStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
        percentage = _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
        isComplete = _pStorage.getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));

        return (title, description, percentage, isComplete);
    }

    function _getTimelineMilestone(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        string memory title = _pStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
        string memory description = _pStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
        uint percentage = _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
        bool isComplete = _pStorage.getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getPendingTimelineMilestoneTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
    }

    function getPendingTimelineMilestoneDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
    }

    function getPendingTimelineMilestonePercentage(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
    }

    function getPendingTimelineMilestoneIsComplete(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));
    }

    function getPendingTimelineMilestone(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string memory title, string memory description, uint percentage, bool isComplete) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        title = _pStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
        description = _pStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
        percentage = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
        isComplete = _pStorage.getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));

        return (title, description, percentage, isComplete);
    }

    function _getPendingTimelineMilestone(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        string memory title = _pStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
        string memory description = _pStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
        uint percentage = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
        bool isComplete = _pStorage.getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getCompletedMilestonesLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)));
    }

    function getCompletedMilestoneTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
    }

    function getCompletedMilestoneDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
    }

    function getCompletedMilestonePercentage(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
    }

    function getCompletedMilestoneIsComplete(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));
    }

    function getCompletedMilestone(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string memory title, string memory description, uint percentage, bool isComplete) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        title = _pStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
        description = _pStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
        percentage = _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
        isComplete = _pStorage.getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));

        return (title, description, percentage, isComplete);
    }

    function _getCompletedMilestone(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        string memory title = _pStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
        string memory description = _pStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
        uint percentage = _pStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
        bool isComplete = _pStorage.getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getTimelineHistoryMilestonesLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)));
    }

    function getTimelineHistoryMilestoneTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestoneDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestonePercentage(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (uint) {
        require(_timelineIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestoneIsComplete(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (bool) {
        require(_timelineIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return _pStorage.getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestone(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string memory title, string memory description, uint percentage, bool isComplete) {
        require(_timelineIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        title = _pStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
        description = _pStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
        percentage = _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
        isComplete = _pStorage.getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));

        return (title, description, percentage, isComplete);
    }

    function _getTimelineHistoryMilestone(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (Milestone) {
        require(_timelineIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        string memory title = _pStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
        string memory description = _pStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
        uint percentage = _pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
        bool isComplete = _pStorage.getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    // ContributionTier

    function getContributionTiersLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)));
    }

    function getContributionTierContributorLimit(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
    }

    function getContributionTierMinContribution(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
    }

    function getContributionTierMaxContribution(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
    }

    function getContributionTierRewards(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));
    }

    function getContributionTier(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint contributorLimit, uint minContribution, uint maxContribution, string rewards) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        contributorLimit = _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
        minContribution = _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
        maxContribution = _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
        rewards = _pStorage.getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));

        return (contributorLimit, minContribution, maxContribution, rewards);
    }

    function _getContributionTier(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        uint contributorLimit = _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
        uint minContribution = _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
        uint maxContribution = _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
        string memory rewards = _pStorage.getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    function getPendingContributionTiersLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)));
    }

    function getPendingContributionTierContributorLimit(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
    }

    function getPendingContributionTierMinContribution(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
    }

    function getPendingContributionTierMaxContribution(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
    }

    function getPendingContributionTierRewards(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _pStorage.getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));
    }

    function getPendingContributionTier(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (uint contributorLimit, uint minContribution, uint maxContribution, string rewards) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        contributorLimit = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
        minContribution = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
        maxContribution = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
        rewards = _pStorage.getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));

        return (contributorLimit, minContribution, maxContribution, rewards);
    }

    function _getPendingContributionTier(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        uint contributorLimit = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
        uint minContribution = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
        uint maxContribution = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
        string memory rewards = _pStorage.getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    // TimelineProposal

    function getTimelineProposalTimestamp(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
    }

    function getTimelineProposalApprovalCount(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
    }

    function getTimelineProposalDisapprovalCount(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
    }

    function getTimelineProposalIsActive(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
    }

    function getTimelineProposalHasFailed(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));
    }

    function getTimelineProposalHasVoted(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, address _address) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)));
    }

    function getTimelineProposal(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint timestamp, uint approvalCount, uint disapprovalCount, bool isActive, bool hasFailed) {
        timestamp = _pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
        approvalCount = _pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
        disapprovalCount = _pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
        isActive = _pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
        hasFailed = _pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));

        return (timestamp, approvalCount, disapprovalCount, isActive, hasFailed);
    }


    function _getTimelineProposal(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (TimelineProposal) {
        uint timestamp = _pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
        uint approvalCount = _pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
        uint disapprovalCount = _pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
        bool isActive = _pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
        bool hasFailed = _pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));

        TimelineProposal memory timelineProposal = TimelineProposal({
            timestamp: timestamp,
            approvalCount: approvalCount,
            disapprovalCount: disapprovalCount,
            isActive: isActive,
            hasFailed: hasFailed
            });

        return timelineProposal;
    }

    // MilestoneCompletionSubmission

    function getMilestoneCompletionSubmissionTimestamp(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
    }

    function getMilestoneCompletionSubmissionApprovalCount(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionDisapprovalCount(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint) {
        return _pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionReport(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (string) {
        return _pStorage.getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
    }

    function getMilestoneCompletionSubmissionIsActive(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasFailed(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasVoted(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, address _address) internal view returns (bool) {
        return _pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)));
    }

    function getMilestoneCompletionSubmission(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (uint timestamp, uint approvalCount, uint disapprovalCount, string report, bool isActive, bool hasFailed) {
        timestamp = _pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
        approvalCount = _pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
        disapprovalCount = _pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
        report = _pStorage.getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
        isActive = _pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
        hasFailed = _pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));

        return (timestamp, approvalCount, disapprovalCount, report, isActive, hasFailed);
    }

    function _getMilestoneCompletionSubmission(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (MilestoneCompletionSubmission) {
        uint timestamp = _pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
        uint approvalCount = _pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
        uint disapprovalCount = _pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
        string memory report = _pStorage.getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
        bool isActive = _pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
        bool hasFailed = _pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));

        MilestoneCompletionSubmission memory submission = MilestoneCompletionSubmission({
            timestamp: timestamp,
            approvalCount: approvalCount,
            disapprovalCount: disapprovalCount,
            report: report,
            isActive: isActive,
            hasFailed: hasFailed
            });

        return submission;
    }

    // Miscellaneous

    function getProject(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal view returns (bool, uint, string, string, string, uint, address, uint) {
        bool isActive = _pStorage.getBool(keccak256(abi.encodePacked("project.activeProjects", _projectId)));
        uint status = _pStorage.getUint(keccak256(abi.encodePacked("project.status", _projectId)));
        string memory title = _pStorage.getString(keccak256(abi.encodePacked("project.title", _projectId)));
        string memory description = _pStorage.getString(keccak256(abi.encodePacked("project.description", _projectId)));
        string memory about = _pStorage.getString(keccak256(abi.encodePacked("project.about", _projectId)));
        uint contributionGoal = _pStorage.getUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)));
        address developer = _pStorage.getAddress(keccak256(abi.encodePacked("project.developer", _projectId)));
        uint developerId = _pStorage.getUint(keccak256(abi.encodePacked("project.developerId", _projectId)));

        return (isActive, status, title, description, about, contributionGoal, developer, developerId);
    }



    // // Setters

    function incrementNextId(ProjectEternalStorage.ProjectStorage storage _pStorage) internal {
        uint currentId = _pStorage.getUint(keccak256("project.nextId"));
        _pStorage.setUint(keccak256("project.nextId"), currentId + 1);
    }

    function setProjectIsActive(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, bool _isActive) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.activeProjects", _projectId)), _isActive);
    }

    function setStatus(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _status) internal {
        _pStorage.setUint(keccak256(abi.encodePacked("project.status", _projectId)), _status);
    }

    function setTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, string _title) internal {
        _pStorage.setString(keccak256(abi.encodePacked("project.title", _projectId)), _title);
    }

    function setDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, string _description) internal {
        _pStorage.setString(keccak256(abi.encodePacked("project.description", _projectId)), _description);
    }

    function setAbout(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, string _about) internal {
        _pStorage.setString(keccak256(abi.encodePacked("project.about", _projectId)), _about);
    }

    function setDeveloper(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, address _developer) internal {
        _pStorage.setAddress(keccak256(abi.encodePacked("project.developer", _projectId)), _developer);
    }

    function setDeveloperId(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _developerId) internal {
        _pStorage.setUint(keccak256(abi.encodePacked("project.developerId", _projectId)), _developerId);
    }

    function setContributionGoal(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _goal) internal {
        _pStorage.setUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)), _goal);
    }

    function setNoRefunds(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, bool _noRefunds) internal {
        _pStorage.setBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)), _noRefunds);
    }

    function setNoTimeline(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, bool _noTimeline) internal {
        _pStorage.setBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)), _noTimeline);
    }

    function setActiveMilestoneIndex(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index) internal {
        _pStorage.setUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)), _index);
    }

    // Timeline

    function setTimelineIsActive(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, bool _isActive) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.timeline.isActive", _projectId)), _isActive);
    }

    function setTimelineLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _length) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)), _length);
    }

    function setPendingTimelineLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _length) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)), _length);
    }

    function setTimelineHistoryLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _length) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)), _length);
    }

    // Milestone

    function setTimelineMilestoneTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, string _title) internal {
        return _pStorage.setString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)), _title);
    }

    function setTimelineMilestoneDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, string _description) internal {
        return _pStorage.setString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)), _description);
    }

    function setTimelineMilestonePercentage(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, uint _percentage) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function setTimelineMilestoneIsComplete(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setTimelineMilestone(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        _pStorage.setString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)), _title);
        _pStorage.setString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)), _description);
        _pStorage.setUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)), _percentage);
        _pStorage.setBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setPendingTimelineMilestoneTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, string _title) internal {
        return _pStorage.setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)), _title);
    }

    function setPendingTimelineMilestoneDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, string _description) internal {
        return _pStorage.setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)), _description);
    }

    function setPendingTimelineMilestonePercentage(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, uint _percentage) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function setPendingTimelineMilestoneIsComplete(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setPendingTimelineMilestone(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        _pStorage.setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)), _title);
        _pStorage.setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)), _description);
        _pStorage.setUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)), _percentage);
        _pStorage.setBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setCompletedMilestonesLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _length) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)), _length);
    }

    function setCompletedMilestoneTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, string _title) internal {
        return _pStorage.setString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)), _title);
    }

    function setCompletedMilestoneDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, string _description) internal {
        return _pStorage.setString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)), _description);
    }

    function setCompletedMilestonePercentage(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, uint _percentage) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)), _percentage);
    }

    function setCompletedMilestoneIsComplete(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setCompletedMilestone(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        _pStorage.setString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)), _title);
        _pStorage.setString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)), _description);
        _pStorage.setUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)), _percentage);
        _pStorage.setBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setTimelineHistoryMilestonesLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _length) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)), _length);
    }

    function setTimelineHistoryMilestoneTitle(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _title) internal {
        return _pStorage.setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _projectId, _timelineIndex, _milestoneIndex)), _title);
    }

    function setTimelineHistoryMilestoneDescription(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _description) internal {
        return _pStorage.setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _projectId, _timelineIndex, _milestoneIndex)), _description);
    }

    function setTimelineHistoryMilestonePercentage(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, uint _percentage) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _projectId, _timelineIndex, _milestoneIndex)), _percentage);
    }

    function setTimelineHistoryMilestoneIsComplete(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, bool _isComplete) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _projectId, _timelineIndex, _milestoneIndex)), _isComplete);
    }

    function setTimelineHistoryMilestone(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        uint _projectId,
        uint _timelineIndex,
        uint _milestoneIndex,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        _pStorage.setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _projectId, _timelineIndex, _milestoneIndex)), _title);
        _pStorage.setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _projectId, _timelineIndex, _milestoneIndex)), _description);
        _pStorage.setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _projectId, _timelineIndex, _milestoneIndex)), _percentage);
        _pStorage.setBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _projectId, _timelineIndex, _milestoneIndex)), _isComplete);
    }



    // // ContributionTier

    function setContributionTiersLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _length) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)), _length);
    }

    function setContributionTierContributorLimit(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, uint _limit) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setContributionTierMinContribution(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, uint _min) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setContributionTierMaxContribution(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, uint _max) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setContributionTierRewards(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, string _rewards) internal {
        _pStorage.setString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setContributionTier(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _minContribution,
        uint _maxContribution,
        string _rewards
    )
    internal
    {
        _pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)), _contributorLimit);
        _pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)), _minContribution);
        _pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)), _maxContribution);
        _pStorage.setString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setPendingContributionTiersLength(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _length) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)), _length);
    }

    function setPendingContributionTierContributorLimit(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, uint _limit) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setPendingContributionTierMinContribution(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, uint _min) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setPendingContributionTierMaxContribution(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, uint _max) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setPendingContributionTierRewards(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _index, string _rewards) internal {
        _pStorage.setString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setPendingContributionTier(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _minContribution,
        uint _maxContribution,
        string _rewards
    )
    internal
    {
        _pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)), _contributorLimit);
        _pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)), _minContribution);
        _pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)), _maxContribution);
        _pStorage.setString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)), _rewards);
    }

    // TimelineProposal

    function setTimelineProposalTimestamp(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timestamp) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)), _timestamp);
    }

    function setTimelineProposalApprovalCount(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _count) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)), _count);
    }

    function setTimelineProposalDisapprovalCount(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _count) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)), _count);
    }

    function setTimelineProposalIsActive(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, bool _isActive) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)), _isActive);
    }

    function setTimelineProposalHasFailed(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, bool _hasFailed) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)), _hasFailed);
    }

    function setTimelineProposalHasVoted(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, address _address, bool _vote) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)), _vote);
    }

    function setTimelineProposal(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        uint _projectId,
        uint _timestamp,
        uint _approvalCount,
        uint _disapprovalCount,
        bool _isActive,
        bool _hasFailed
    )
    internal
    {
        _pStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)), _timestamp);
        _pStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)), _approvalCount);
        _pStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)), _disapprovalCount);
        _pStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)), _isActive);
        _pStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)), _hasFailed);
    }

    // MilestoneCompletionSubmission

    function setMilestoneCompletionSubmissionTimestamp(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _timestamp) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)), _timestamp);
    }

    function setMilestoneCompletionSubmissionApprovalCount(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _count) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionDisapprovalCount(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, uint _count) internal {
        return _pStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionReport(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, string _report) internal {
        return _pStorage.setString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)), _report);
    }

    function setMilestoneCompletionSubmissionIsActive(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, bool _isActive) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)), _isActive);
    }

    function setMilestoneCompletionSubmissionHasFailed(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, bool _hasFailed) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)), _hasFailed);
    }

    function setMilestoneCompletionSubmissionHasVoted(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId, address _address, bool _vote) internal {
        return _pStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)), _vote);
    }

    function setMilestoneCompletionSubmission(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        uint _projectId,
        uint _timestamp,
        uint _approvalCount,
        uint _disapprovalCount,
        string _report,
        bool _isActive,
        bool _hasFailed
    )
    internal
    {
        _pStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)), _timestamp);
        _pStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)), _approvalCount);
        _pStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)), _disapprovalCount);
        _pStorage.setString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)), _report);
        _pStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)), _isActive);
        _pStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)), _hasFailed);
    }

    // Miscellaneous

    function setProject(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        uint _projectId,
        string _title,
        string _description,
        string _about,
        uint _contributionGoal,
        uint _status,
        address _developer,
        uint _developerId
    )
    internal
    {
        _pStorage.setUint(keccak256(abi.encodePacked("project.status", _projectId)), _status);
        _pStorage.setString(keccak256(abi.encodePacked("project.title", _projectId)), _title);
        _pStorage.setString(keccak256(abi.encodePacked("project.description", _projectId)), _description);
        _pStorage.setString(keccak256(abi.encodePacked("project.about", _projectId)), _about);
        _pStorage.setAddress(keccak256(abi.encodePacked("project.developer", _projectId)), _developer);
        _pStorage.setUint(keccak256(abi.encodePacked("project.developerId", _projectId)), _developerId);
        _pStorage.setUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)), _contributionGoal);
    }



    // // Deletion

    function deleteContributionTiers(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal {
        uint length = _pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            _pStorage.deleteUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", i, _projectId)));
            _pStorage.deleteUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", i, _projectId)));
            _pStorage.deleteUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", i, _projectId)));
            _pStorage.deleteString(keccak256(abi.encodePacked("project.contributionTiers.rewards", i, _projectId)));
        }

        _pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)), 0);
    }

    function deletePendingContributionTiers(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal {
        uint length = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            _pStorage.deleteUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", i, _projectId)));
            _pStorage.deleteUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", i, _projectId)));
            _pStorage.deleteUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", i, _projectId)));
            _pStorage.deleteString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", i, _projectId)));
        }

        _pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)), 0);
    }

    function deleteTimeline(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal {
        uint length = _pStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            _pStorage.deleteString(keccak256(abi.encodePacked("project.timeline.milestones.title", i, _projectId)));
            _pStorage.deleteString(keccak256(abi.encodePacked("project.timeline.milestones.description", i, _projectId)));
            _pStorage.deleteUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", i, _projectId)));
            _pStorage.deleteBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", i, _projectId)));
        }

        _pStorage.setUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)), 0);
    }

    function deletePendingTimeline(ProjectEternalStorage.ProjectStorage storage _pStorage, uint _projectId) internal {
        uint length = _pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            _pStorage.deleteString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", i, _projectId)));
            _pStorage.deleteString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", i, _projectId)));
            _pStorage.deleteUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", i, _projectId)));
            _pStorage.deleteBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", i, _projectId)));
        }

        _pStorage.setUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)), 0);
    }
}
