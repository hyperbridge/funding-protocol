pragma solidity ^0.4.24;

import "../FundingStorage.sol";

library ProjectStorageAccess {

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
        Each project stores the following data in FundingStorage and accesses it through the associated namespace:
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

    function getNextProjectId(address _pStorage) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256("project.nextId"));
    }

    function getProjectIsActive(address _pStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.activeProjects", _projectId)));
    }

    function getProjectStatus(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.status", _projectId)));
    }

    function getProjectTitle(address _pStorage, uint _projectId) internal view returns (string) {
        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.title", _projectId)));
    }

    function getProjectDescription(address _pStorage, uint _projectId) internal view returns (string) {
        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.description", _projectId)));
    }

    function getProjectAbout(address _pStorage, uint _projectId) internal view returns (string) {
        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.about", _projectId)));
    }

    function getProjectDeveloper(address _pStorage, uint _projectId) internal view returns (address) {
        return FundingStorage(_pStorage).getAddress(keccak256(abi.encodePacked("project.developer", _projectId)));
    }

    function getProjectDeveloperId(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.developerId", _projectId)));
    }

    function getProjectContributionGoal(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)));
    }

    function getProjectNoRefunds(address _pStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)));
    }

    function getProjectNoTimeline(address _pStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)));
    }

    function getActiveMilestoneIndex(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)));
    }

    // Timeline

    function getTimelineIsActive(address _pStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timeline.isActive", _projectId)));
    }

    function getTimelineLength(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)));
    }

    function getPendingTimelineLength(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)));
    }

    function getTimelineHistoryLength(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)));
    }

    // Milestone

    function getTimelineMilestoneTitle(address _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
    }

    function getTimelineMilestoneDescription(address _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
    }

    function getTimelineMilestonePercentage(address _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
    }

    function getTimelineMilestoneIsComplete(address _pStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));
    }

    function getTimelineMilestone(address _pStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        string memory title = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
        string memory description = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
        uint percentage = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
        bool isComplete = FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getPendingTimelineMilestoneTitle(address _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
    }

    function getPendingTimelineMilestoneDescription(address _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
    }

    function getPendingTimelineMilestonePercentage(address _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
    }

    function getPendingTimelineMilestoneIsComplete(address _pStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));
    }

    function getPendingTimelineMilestone(address _pStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        string memory title = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
        string memory description = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
        uint percentage = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
        bool isComplete = FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getCompletedMilestonesLength(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)));
    }

    function getCompletedMilestoneTitle(address _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
    }

    function getCompletedMilestoneDescription(address _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
    }

    function getCompletedMilestonePercentage(address _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
    }

    function getCompletedMilestoneIsComplete(address _pStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));
    }

    function getCompletedMilestone(address _pStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        string memory title = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
        string memory description = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
        uint percentage = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
        bool isComplete = FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getTimelineHistoryMilestonesLength(address _pStorage, uint _projectId, uint _timelineIndex) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)));
    }

    function getTimelineHistoryMilestoneTitle(address _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestoneDescription(address _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestonePercentage(address _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (uint) {
        require(_timelineIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestoneIsComplete(address _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (bool) {
        require(_timelineIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestone(address _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (Milestone) {
        require(_timelineIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        string memory title = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
        string memory description = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
        uint percentage = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
        bool isComplete = FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    // ContributionTier

    function getContributionTiersLength(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)));
    }

    function getContributionTierContributorLimit(address _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
    }

    function getContributionTierMinContribution(address _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
    }

    function getContributionTierMaxContribution(address _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
    }

    function getContributionTierRewards(address _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));
    }

    function getContributionTier(address _pStorage, uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        uint contributorLimit = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
        uint minContribution = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
        uint maxContribution = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
        string memory rewards = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    function getPendingContributionTiersLength(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)));
    }

    function getPendingContributionTierContributorLimit(address _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
    }

    function getPendingContributionTierMinContribution(address _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
    }

    function getPendingContributionTierMaxContribution(address _pStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
    }

    function getPendingContributionTierRewards(address _pStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));
    }

    function getPendingContributionTier(address _pStorage, uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        uint contributorLimit = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
        uint minContribution = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
        uint maxContribution = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
        string memory rewards = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    // TimelineProposal

    function getTimelineProposalTimestamp(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
    }

    function getTimelineProposalApprovalCount(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
    }

    function getTimelineProposalDisapprovalCount(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
    }

    function getTimelineProposalIsActive(address _pStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
    }

    function getTimelineProposalHasFailed(address _pStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));
    }

    function getTimelineProposalHasVoted(address _pStorage, uint _projectId, address _address) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)));
    }

    function getTimelineProposal(address _pStorage, uint _projectId) internal view returns (TimelineProposal) {
        uint timestamp = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
        uint approvalCount = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
        uint disapprovalCount = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
        bool isActive = FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
        bool hasFailed = FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));

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

    function getMilestoneCompletionSubmissionTimestamp(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
    }

    function getMilestoneCompletionSubmissionApprovalCount(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionDisapprovalCount(address _pStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionReport(address _pStorage, uint _projectId) internal view returns (string) {
        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
    }

    function getMilestoneCompletionSubmissionIsActive(address _pStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasFailed(address _pStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasVoted(address _pStorage, uint _projectId, address _address) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)));
    }

    function getMilestoneCompletionSubmission(address _pStorage, uint _projectId) internal view returns (MilestoneCompletionSubmission) {
        uint timestamp = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
        uint approvalCount = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
        uint disapprovalCount = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
        string memory report = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
        bool isActive = FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
        bool hasFailed = FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));

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

    function getProject(address _pStorage, uint _projectId) internal view returns (bool, uint, string, string, string, uint, address, uint) {
        bool isActive = FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("project.activeProjects", _projectId)));
        uint status = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.status", _projectId)));
        string memory title = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.title", _projectId)));
        string memory description = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.description", _projectId)));
        string memory about = FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("project.about", _projectId)));
        uint contributionGoal = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)));
        address developer = FundingStorage(_pStorage).getAddress(keccak256(abi.encodePacked("project.developer", _projectId)));
        uint developerId = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.developerId", _projectId)));

        return (isActive, status, title, description, about, contributionGoal, developer, developerId);
    }



    // // Setters

    function incrementNextProjectId(address _pStorage) internal {
        uint currentId = FundingStorage(_pStorage).getUint(keccak256("project.nextId"));
        FundingStorage(_pStorage).setUint(keccak256("project.nextId"), currentId + 1);
    }

    function setProjectIsActive(address _pStorage, uint _projectId, bool _isActive) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.activeProjects", _projectId)), _isActive);
    }

    function setProjectStatus(address _pStorage, uint _projectId, uint _status) internal {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.status", _projectId)), _status);
    }

    function setProjectTitle(address _pStorage, uint _projectId, string _title) internal {
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.title", _projectId)), _title);
    }

    function setProjectDescription(address _pStorage, uint _projectId, string _description) internal {
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.description", _projectId)), _description);
    }

    function setProjectAbout(address _pStorage, uint _projectId, string _about) internal {
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.about", _projectId)), _about);
    }

    function setProjectDeveloper(address _pStorage, uint _projectId, address _developer) internal {
        FundingStorage(_pStorage).setAddress(keccak256(abi.encodePacked("project.developer", _projectId)), _developer);
    }

    function setProjectDeveloperId(address _pStorage, uint _projectId, uint _developerId) internal {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.developerId", _projectId)), _developerId);
    }

    function setProjectContributionGoal(address _pStorage, uint _projectId, uint _goal) internal {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)), _goal);
    }

    function setProjectNoRefunds(address _pStorage, uint _projectId, bool _noRefunds) internal {
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)), _noRefunds);
    }

    function setProjectNoTimeline(address _pStorage, uint _projectId, bool _noTimeline) internal {
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)), _noTimeline);
    }

    function setActiveMilestoneIndex(address _pStorage, uint _projectId, uint _index) internal {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)), _index);
    }

    // Timeline

    function setTimelineIsActive(address _pStorage, uint _projectId, bool _isActive) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timeline.isActive", _projectId)), _isActive);
    }

    function setTimelineLength(address _pStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)), _length);
    }

    function setPendingTimelineLength(address _pStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)), _length);
    }

    function setTimelineHistoryLength(address _pStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)), _length);
    }

    // Milestone

    function setTimelineMilestoneTitle(address _pStorage, uint _projectId, uint _index, string _title) internal {
        return FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)), _title);
    }

    function setTimelineMilestoneDescription(address _pStorage, uint _projectId, uint _index, string _description) internal {
        return FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)), _description);
    }

    function setTimelineMilestonePercentage(address _pStorage, uint _projectId, uint _index, uint _percentage) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function setTimelineMilestoneIsComplete(address _pStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setTimelineMilestone(
        address _pStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)), _title);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)), _description);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)), _percentage);
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setPendingTimelineMilestoneTitle(address _pStorage, uint _projectId, uint _index, string _title) internal {
        return FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)), _title);
    }

    function setPendingTimelineMilestoneDescription(address _pStorage, uint _projectId, uint _index, string _description) internal {
        return FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)), _description);
    }

    function setPendingTimelineMilestonePercentage(address _pStorage, uint _projectId, uint _index, uint _percentage) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function setPendingTimelineMilestoneIsComplete(address _pStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setPendingTimelineMilestone(
        address _pStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)), _title);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)), _description);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)), _percentage);
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setCompletedMilestonesLength(address _pStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)), _length);
    }

    function setCompletedMilestoneTitle(address _pStorage, uint _projectId, uint _index, string _title) internal {
        return FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)), _title);
    }

    function setCompletedMilestoneDescription(address _pStorage, uint _projectId, uint _index, string _description) internal {
        return FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)), _description);
    }

    function setCompletedMilestonePercentage(address _pStorage, uint _projectId, uint _index, uint _percentage) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)), _percentage);
    }

    function setCompletedMilestoneIsComplete(address _pStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setCompletedMilestone(
        address _pStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)), _title);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)), _description);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)), _percentage);
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setTimelineHistoryMilestonesLength(address _pStorage, uint _projectId, uint _timelineIndex, uint _length) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)), _length);
    }

    function setTimelineHistoryMilestoneTitle(address _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _title) internal {
        return FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _projectId, _timelineIndex, _milestoneIndex)), _title);
    }

    function setTimelineHistoryMilestoneDescription(address _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _description) internal {
        return FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _projectId, _timelineIndex, _milestoneIndex)), _description);
    }

    function setTimelineHistoryMilestonePercentage(address _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, uint _percentage) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _projectId, _timelineIndex, _milestoneIndex)), _percentage);
    }

    function setTimelineHistoryMilestoneIsComplete(address _pStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, bool _isComplete) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _projectId, _timelineIndex, _milestoneIndex)), _isComplete);
    }

    function setTimelineHistoryMilestone(
        address _pStorage,
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
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _projectId, _timelineIndex, _milestoneIndex)), _title);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _projectId, _timelineIndex, _milestoneIndex)), _description);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _projectId, _timelineIndex, _milestoneIndex)), _percentage);
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _projectId, _timelineIndex, _milestoneIndex)), _isComplete);
    }



    // // ContributionTier

    function setContributionTiersLength(address _pStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)), _length);
    }

    function setContributionTierContributorLimit(address _pStorage, uint _projectId, uint _index, uint _limit) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setContributionTierMinContribution(address _pStorage, uint _projectId, uint _index, uint _min) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setContributionTierMaxContribution(address _pStorage, uint _projectId, uint _index, uint _max) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setContributionTierRewards(address _pStorage, uint _projectId, uint _index, string _rewards) internal {
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setContributionTier(
        address _pStorage,
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _minContribution,
        uint _maxContribution,
        string _rewards
    )
    internal
    {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)), _contributorLimit);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)), _minContribution);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)), _maxContribution);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setPendingContributionTiersLength(address _pStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)), _length);
    }

    function setPendingContributionTierContributorLimit(address _pStorage, uint _projectId, uint _index, uint _limit) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setPendingContributionTierMinContribution(address _pStorage, uint _projectId, uint _index, uint _min) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setPendingContributionTierMaxContribution(address _pStorage, uint _projectId, uint _index, uint _max) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setPendingContributionTierRewards(address _pStorage, uint _projectId, uint _index, string _rewards) internal {
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setPendingContributionTier(
        address _pStorage,
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _minContribution,
        uint _maxContribution,
        string _rewards
    )
    internal
    {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)), _contributorLimit);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)), _minContribution);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)), _maxContribution);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)), _rewards);
    }

    // TimelineProposal

    function setTimelineProposalTimestamp(address _pStorage, uint _projectId, uint _timestamp) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)), _timestamp);
    }

    function setTimelineProposalApprovalCount(address _pStorage, uint _projectId, uint _count) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)), _count);
    }

    function setTimelineProposalDisapprovalCount(address _pStorage, uint _projectId, uint _count) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)), _count);
    }

    function setTimelineProposalIsActive(address _pStorage, uint _projectId, bool _isActive) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)), _isActive);
    }

    function setTimelineProposalHasFailed(address _pStorage, uint _projectId, bool _hasFailed) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)), _hasFailed);
    }

    function setTimelineProposalHasVoted(address _pStorage, uint _projectId, address _address, bool _vote) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)), _vote);
    }

    function setTimelineProposal(
        address _pStorage,
        uint _projectId,
        uint _timestamp,
        uint _approvalCount,
        uint _disapprovalCount,
        bool _isActive,
        bool _hasFailed
    )
    internal
    {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)), _timestamp);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)), _approvalCount);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)), _disapprovalCount);
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)), _isActive);
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)), _hasFailed);
    }

    // MilestoneCompletionSubmission

    function setMilestoneCompletionSubmissionTimestamp(address _pStorage, uint _projectId, uint _timestamp) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)), _timestamp);
    }

    function setMilestoneCompletionSubmissionApprovalCount(address _pStorage, uint _projectId, uint _count) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionDisapprovalCount(address _pStorage, uint _projectId, uint _count) internal {
        return FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionReport(address _pStorage, uint _projectId, string _report) internal {
        return FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)), _report);
    }

    function setMilestoneCompletionSubmissionIsActive(address _pStorage, uint _projectId, bool _isActive) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)), _isActive);
    }

    function setMilestoneCompletionSubmissionHasFailed(address _pStorage, uint _projectId, bool _hasFailed) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)), _hasFailed);
    }

    function setMilestoneCompletionSubmissionHasVoted(address _pStorage, uint _projectId, address _address, bool _vote) internal {
        return FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)), _vote);
    }

    function setMilestoneCompletionSubmission(
        address _pStorage,
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
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)), _timestamp);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)), _approvalCount);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)), _disapprovalCount);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)), _report);
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)), _isActive);
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)), _hasFailed);
    }

    // Miscellaneous

    function setProject(
        address _pStorage,
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
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.status", _projectId)), _status);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.title", _projectId)), _title);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.description", _projectId)), _description);
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("project.about", _projectId)), _about);
        FundingStorage(_pStorage).setAddress(keccak256(abi.encodePacked("project.developer", _projectId)), _developer);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.developerId", _projectId)), _developerId);
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)), _contributionGoal);
    }



    // // Deletion

    function deleteContributionTiers(address _pStorage, uint _projectId) internal {
        uint length = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            FundingStorage(_pStorage).deleteUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", i, _projectId)));
            FundingStorage(_pStorage).deleteUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", i, _projectId)));
            FundingStorage(_pStorage).deleteUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", i, _projectId)));
            FundingStorage(_pStorage).deleteString(keccak256(abi.encodePacked("project.contributionTiers.rewards", i, _projectId)));
        }

        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)), 0);
    }

    function deletePendingContributionTiers(address _pStorage, uint _projectId) internal {
        uint length = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            FundingStorage(_pStorage).deleteUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", i, _projectId)));
            FundingStorage(_pStorage).deleteUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", i, _projectId)));
            FundingStorage(_pStorage).deleteUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", i, _projectId)));
            FundingStorage(_pStorage).deleteString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", i, _projectId)));
        }

        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)), 0);
    }

    function deleteTimeline(address _pStorage, uint _projectId) internal {
        uint length = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            FundingStorage(_pStorage).deleteString(keccak256(abi.encodePacked("project.timeline.milestones.title", i, _projectId)));
            FundingStorage(_pStorage).deleteString(keccak256(abi.encodePacked("project.timeline.milestones.description", i, _projectId)));
            FundingStorage(_pStorage).deleteUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", i, _projectId)));
            FundingStorage(_pStorage).deleteBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", i, _projectId)));
        }

        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)), 0);
    }

    function deletePendingTimeline(address _pStorage, uint _projectId) internal {
        uint length = FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            FundingStorage(_pStorage).deleteString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", i, _projectId)));
            FundingStorage(_pStorage).deleteString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", i, _projectId)));
            FundingStorage(_pStorage).deleteUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", i, _projectId)));
            FundingStorage(_pStorage).deleteBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", i, _projectId)));
        }

        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)), 0);
    }
}
