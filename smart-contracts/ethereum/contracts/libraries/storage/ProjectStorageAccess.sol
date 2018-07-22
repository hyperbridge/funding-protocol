pragma solidity ^0.4.24;

import "../../FundingStorage.sol";

library ProjectStorageAccess {

    struct Timeline {
        Milestone[] milestones;
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
            uint minContributionGoal                                        (project.minContributionGoal)
            uint maxContributionGoal                                        (project.maxContributionGoal)
            uint contributionPeriod                                         (project.contributionPeriod)
            bool noRefunds                                                  (project.noRefunds)
            bool noTimeline                                                 (project.noTimeline)
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
            Timeline timeline
                Milestone[] milestones
                    Milestone
                        string title                                        (project.timeline.milestones.title)
                        string description                                  (project.timeline.milestones.description)
                        uint percentage                                     (project.timeline.milestones.percentage)
                        bool isComplete                                     (project.timeline.milestones.isComplete)
            uint activeMilestoneIndex                                       (project.activeMilestoneIndex)
            Timeline pendingTimeline
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

    function generateNewProjectId(address _fundingStorage) internal returns (uint) {
        uint id = getNextProjectId(_fundingStorage);
        incrementNextProjectId(_fundingStorage);
        return id;
    }

    function getNextProjectId(address _fundingStorage) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256("project.nextId"));
    }

    function getProjectStatus(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.status", _projectId)));
    }

    function getProjectTitle(address _fundingStorage, uint _projectId) internal view returns (string) {
        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.title", _projectId)));
    }

    function getProjectDescription(address _fundingStorage, uint _projectId) internal view returns (string) {
        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.description", _projectId)));
    }

    function getProjectAbout(address _fundingStorage, uint _projectId) internal view returns (string) {
        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.about", _projectId)));
    }

    function getProjectDeveloper(address _fundingStorage, uint _projectId) internal view returns (address) {
        return FundingStorage(_fundingStorage).getAddress(keccak256(abi.encodePacked("project.developer", _projectId)));
    }

    function getProjectDeveloperId(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.developerId", _projectId)));
    }

    function getProjectMinContributionGoal(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.minContributionGoal", _projectId)));
    }

    function getProjectMaxContributionGoal(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.maxContributionGoal", _projectId)));
    }

    function getProjectContributionPeriod(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionPeriod", _projectId)));
    }

    function getProjectNoRefunds(address _fundingStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)));
    }

    function getProjectNoTimeline(address _fundingStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)));
    }

    function getActiveMilestoneIndex(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)));
    }

    // Timeline

    function getTimelineLength(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)));
    }

    function getPendingTimelineLength(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)));
    }

    function getTimelineHistoryLength(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)));
    }

    // Milestone

    function getTimelineMilestoneTitle(address _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
    }

    function getTimelineMilestoneDescription(address _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
    }

    function getTimelineMilestonePercentage(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
    }

    function getTimelineMilestoneIsComplete(address _fundingStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));
    }

    function getTimelineMilestone(address _fundingStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        string memory title = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
        string memory description = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
        uint percentage = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
        bool isComplete = FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
        });

        return milestone;
    }

    function getPendingTimelineMilestoneTitle(address _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
    }

    function getPendingTimelineMilestoneDescription(address _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
    }

    function getPendingTimelineMilestonePercentage(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
    }

    function getPendingTimelineMilestoneIsComplete(address _fundingStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));
    }

    function getPendingTimelineMilestone(address _fundingStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        string memory title = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
        string memory description = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
        uint percentage = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
        bool isComplete = FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getCompletedMilestonesLength(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)));
    }

    function getCompletedMilestoneTitle(address _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
    }

    function getCompletedMilestoneDescription(address _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
    }

    function getCompletedMilestonePercentage(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
    }

    function getCompletedMilestoneIsComplete(address _fundingStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));
    }

    function getCompletedMilestone(address _fundingStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        string memory title = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
        string memory description = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
        uint percentage = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
        bool isComplete = FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getTimelineHistoryMilestonesLength(address _fundingStorage, uint _projectId, uint _timelineIndex) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)));
    }

    function getTimelineHistoryMilestoneTitle(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestoneDescription(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestonePercentage(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (uint) {
        require(_timelineIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestoneIsComplete(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (bool) {
        require(_timelineIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestone(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (Milestone) {
        require(_timelineIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        string memory title = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
        string memory description = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
        uint percentage = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
        bool isComplete = FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    // ContributionTier

    function getContributionTiersLength(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)));
    }

    function getContributionTierContributorLimit(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
    }

    function getContributionTierMinContribution(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
    }

    function getContributionTierMaxContribution(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
    }

    function getContributionTierRewards(address _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));
    }

    function getContributionTier(address _fundingStorage, uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        uint contributorLimit = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
        uint minContribution = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
        uint maxContribution = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
        string memory rewards = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    function getPendingContributionTiersLength(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)));
    }

    function getPendingContributionTierContributorLimit(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
    }

    function getPendingContributionTierMinContribution(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
    }

    function getPendingContributionTierMaxContribution(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
    }

    function getPendingContributionTierRewards(address _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));
    }

    function getPendingContributionTier(address _fundingStorage, uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        uint contributorLimit = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
        uint minContribution = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
        uint maxContribution = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
        string memory rewards = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    // TimelineProposal

    function getTimelineProposalTimestamp(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
    }

    function getTimelineProposalApprovalCount(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
    }

    function getTimelineProposalDisapprovalCount(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
    }

    function getTimelineProposalIsActive(address _fundingStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
    }

    function getTimelineProposalHasFailed(address _fundingStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));
    }

    function getTimelineProposalHasVoted(address _fundingStorage, uint _projectId, address _address) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)));
    }

    function getTimelineProposal(address _fundingStorage, uint _projectId) internal view returns (TimelineProposal) {
        uint timestamp = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
        uint approvalCount = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
        uint disapprovalCount = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
        bool isActive = FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
        bool hasFailed = FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));

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

    function getMilestoneCompletionSubmissionTimestamp(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
    }

    function getMilestoneCompletionSubmissionApprovalCount(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionDisapprovalCount(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionReport(address _fundingStorage, uint _projectId) internal view returns (string) {
        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
    }

    function getMilestoneCompletionSubmissionIsActive(address _fundingStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasFailed(address _fundingStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasVoted(address _fundingStorage, uint _projectId, address _address) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)));
    }

    function getMilestoneCompletionSubmission(address _fundingStorage, uint _projectId) internal view returns (MilestoneCompletionSubmission) {
        uint timestamp = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
        uint approvalCount = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
        uint disapprovalCount = FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
        string memory report = FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
        bool isActive = FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
        bool hasFailed = FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));

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



    // // Setters

    function incrementNextProjectId(address _fundingStorage) internal {
        uint currentId = FundingStorage(_fundingStorage).getUint(keccak256("project.nextId"));
        FundingStorage(_fundingStorage).setUint(keccak256("project.nextId"), currentId + 1);
    }

    function setProjectStatus(address _fundingStorage, uint _projectId, uint _status) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.status", _projectId)), _status);
    }

    function setProjectTitle(address _fundingStorage, uint _projectId, string _title) internal {
        FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.title", _projectId)), _title);
    }

    function setProjectDescription(address _fundingStorage, uint _projectId, string _description) internal {
        FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.description", _projectId)), _description);
    }

    function setProjectAbout(address _fundingStorage, uint _projectId, string _about) internal {
        FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.about", _projectId)), _about);
    }

    function setProjectDeveloper(address _fundingStorage, uint _projectId, address _developer) internal {
        FundingStorage(_fundingStorage).setAddress(keccak256(abi.encodePacked("project.developer", _projectId)), _developer);
    }

    function setProjectDeveloperId(address _fundingStorage, uint _projectId, uint _developerId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.developerId", _projectId)), _developerId);
    }

    function setProjectMinContributionGoal(address _fundingStorage, uint _projectId, uint _goal) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.minContributionGoal", _projectId)), _goal);
    }

    function setProjectMaxContributionGoal(address _fundingStorage, uint _projectId, uint _goal) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.maxContributionGoal", _projectId)), _goal);
    }

    function setProjectContributionPeriod(address _fundingStorage, uint _projectId, uint _weeks) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.contributionPeriod", _projectId)), _weeks);
    }

    function setProjectNoRefunds(address _fundingStorage, uint _projectId, bool _noRefunds) internal {
        FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)), _noRefunds);
    }

    function setProjectNoTimeline(address _fundingStorage, uint _projectId, bool _noTimeline) internal {
        FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)), _noTimeline);
    }

    function setActiveMilestoneIndex(address _fundingStorage, uint _projectId, uint _index) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)), _index);
    }

    // Timeline

    function setTimelineLength(address _fundingStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)), _length);
    }

    function setPendingTimelineLength(address _fundingStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)), _length);
    }

    function setTimelineHistoryLength(address _fundingStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)), _length);
    }

    // Milestone

    function setTimelineMilestoneTitle(address _fundingStorage, uint _projectId, uint _index, string _title) internal {
        return FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)), _title);
    }

    function setTimelineMilestoneDescription(address _fundingStorage, uint _projectId, uint _index, string _description) internal {
        return FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)), _description);
    }

    function setTimelineMilestonePercentage(address _fundingStorage, uint _projectId, uint _index, uint _percentage) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function setTimelineMilestoneIsComplete(address _fundingStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setTimelineMilestone(
        address _fundingStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
        internal
    {
        setTimelineMilestoneTitle(_fundingStorage, _projectId, _index, _title);
        setTimelineMilestoneDescription(_fundingStorage, _projectId, _index, _description);
        setTimelineMilestonePercentage(_fundingStorage, _projectId, _index, _percentage);
        setTimelineMilestoneIsComplete(_fundingStorage, _projectId, _index, _isComplete);
    }

    function pushTimelineMilestone(
        address _fundingStorage,
        uint _projectId,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
        internal
    {
        uint length = getTimelineLength(_fundingStorage, _projectId);

        setTimelineMilestone(_fundingStorage, _projectId, length, _title, _description, _percentage, _isComplete);

        setTimelineLength(_fundingStorage, _projectId, length + 1);
    }

    function setPendingTimelineMilestoneTitle(address _fundingStorage, uint _projectId, uint _index, string _title) internal {
        return FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)), _title);
    }

    function setPendingTimelineMilestoneDescription(address _fundingStorage, uint _projectId, uint _index, string _description) internal {
        return FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)), _description);
    }

    function setPendingTimelineMilestonePercentage(address _fundingStorage, uint _projectId, uint _index, uint _percentage) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function setPendingTimelineMilestoneIsComplete(address _fundingStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setPendingTimelineMilestone(
        address _fundingStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        setPendingTimelineMilestoneTitle(_fundingStorage, _projectId, _index, _title);
        setPendingTimelineMilestoneDescription(_fundingStorage, _projectId, _index, _description);
        setPendingTimelineMilestonePercentage(_fundingStorage, _projectId, _index, _percentage);
        setPendingTimelineMilestoneIsComplete(_fundingStorage, _projectId, _index, _isComplete);
    }

    function pushPendingTimelineMilestone(
        address _fundingStorage,
        uint _projectId,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        uint length = getPendingTimelineLength(_fundingStorage, _projectId);

        setPendingTimelineMilestone(_fundingStorage, _projectId, length, _title, _description, _percentage, _isComplete);

        setPendingTimelineLength(_fundingStorage, _projectId, length + 1);
    }

    function setCompletedMilestonesLength(address _fundingStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)), _length);
    }

    function setCompletedMilestoneTitle(address _fundingStorage, uint _projectId, uint _index, string _title) internal {
        return FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)), _title);
    }

    function setCompletedMilestoneDescription(address _fundingStorage, uint _projectId, uint _index, string _description) internal {
        return FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)), _description);
    }

    function setCompletedMilestonePercentage(address _fundingStorage, uint _projectId, uint _index, uint _percentage) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)), _percentage);
    }

    function setCompletedMilestoneIsComplete(address _fundingStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setCompletedMilestone(
        address _fundingStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
        internal
    {
        setCompletedMilestoneTitle(_fundingStorage, _projectId, _index, _title);
        setCompletedMilestoneDescription(_fundingStorage, _projectId, _index, _description);
        setCompletedMilestonePercentage(_fundingStorage, _projectId, _index, _percentage);
        setCompletedMilestoneIsComplete(_fundingStorage, _projectId, _index, _isComplete);
    }

    function pushCompletedMilestone(
        address _fundingStorage,
        uint _projectId,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
        internal
    {
        uint length = getCompletedMilestonesLength(_fundingStorage, _projectId);

        setCompletedMilestone(_fundingStorage, _projectId, length, _title, _description, _percentage, _isComplete);

        setCompletedMilestonesLength(_fundingStorage, _projectId, length + 1);
    }

    function setTimelineHistoryMilestonesLength(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _length) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)), _length);
    }

    function setTimelineHistoryMilestoneTitle(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _title) internal {
        return FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _projectId, _timelineIndex, _milestoneIndex)), _title);
    }

    function setTimelineHistoryMilestoneDescription(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _description) internal {
        return FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _projectId, _timelineIndex, _milestoneIndex)), _description);
    }

    function setTimelineHistoryMilestonePercentage(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, uint _percentage) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _projectId, _timelineIndex, _milestoneIndex)), _percentage);
    }

    function setTimelineHistoryMilestoneIsComplete(address _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, bool _isComplete) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _projectId, _timelineIndex, _milestoneIndex)), _isComplete);
    }

    function setTimelineHistoryMilestone(
        address _fundingStorage,
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
        setTimelineHistoryMilestoneTitle(_fundingStorage, _projectId, _timelineIndex, _milestoneIndex, _title);
        setTimelineHistoryMilestoneDescription(_fundingStorage, _projectId, _timelineIndex, _milestoneIndex, _description);
        setTimelineHistoryMilestonePercentage(_fundingStorage, _projectId, _timelineIndex, _milestoneIndex, _percentage);
        setTimelineHistoryMilestoneIsComplete(_fundingStorage, _projectId, _timelineIndex, _milestoneIndex, _isComplete);
    }

    function pushTimelineHistoryMilestone(
        address _fundingStorage,
        uint _projectId,
        uint _timelineIndex,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        uint length = getTimelineHistoryMilestonesLength(_fundingStorage, _projectId, _timelineIndex);

        setTimelineHistoryMilestone(_fundingStorage, _projectId, _timelineIndex, length, _title, _description, _percentage, _isComplete);

        setTimelineHistoryMilestonesLength(_fundingStorage, _projectId, _timelineIndex, length + 1);
    }



    // // ContributionTier

    function setContributionTiersLength(address _fundingStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)), _length);
    }

    function setContributionTierContributorLimit(address _fundingStorage, uint _projectId, uint _index, uint _limit) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setContributionTierMinContribution(address _fundingStorage, uint _projectId, uint _index, uint _min) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setContributionTierMaxContribution(address _fundingStorage, uint _projectId, uint _index, uint _max) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setContributionTierRewards(address _fundingStorage, uint _projectId, uint _index, string _rewards) internal {
        FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setContributionTier(
        address _fundingStorage,
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
    internal
    {
        setContributionTierContributorLimit(_fundingStorage, _projectId, _index, _contributorLimit);
        setContributionTierMaxContribution(_fundingStorage, _projectId, _index, _maxContribution);
        setContributionTierMinContribution(_fundingStorage, _projectId, _index, _minContribution);
        setContributionTierRewards(_fundingStorage, _projectId, _index, _rewards);
    }

    function pushContributionTier(
        address _fundingStorage,
        uint _projectId,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
        internal
    {
        uint length = getContributionTiersLength(_fundingStorage, _projectId);

        setContributionTier(_fundingStorage, _projectId, length, _contributorLimit, _maxContribution, _minContribution, _rewards);

        setContributionTiersLength(_fundingStorage, _projectId, length + 1);
    }

    function setPendingContributionTiersLength(address _fundingStorage, uint _projectId, uint _length) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)), _length);
    }

    function setPendingContributionTierContributorLimit(address _fundingStorage, uint _projectId, uint _index, uint _limit) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setPendingContributionTierMinContribution(address _fundingStorage, uint _projectId, uint _index, uint _min) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setPendingContributionTierMaxContribution(address _fundingStorage, uint _projectId, uint _index, uint _max) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setPendingContributionTierRewards(address _fundingStorage, uint _projectId, uint _index, string _rewards) internal {
        FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setPendingContributionTier(
        address _fundingStorage,
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
    internal
    {
        setPendingContributionTierContributorLimit(_fundingStorage, _projectId, _index, _contributorLimit);
        setPendingContributionTierMaxContribution(_fundingStorage, _projectId, _index, _maxContribution);
        setPendingContributionTierMinContribution(_fundingStorage, _projectId, _index, _minContribution);
        setPendingContributionTierRewards(_fundingStorage, _projectId, _index, _rewards);
    }

    function pushPendingContributionTier(
        address _fundingStorage,
        uint _projectId,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
    internal
    {
        uint length = getPendingContributionTiersLength(_fundingStorage, _projectId);

        setPendingContributionTier(_fundingStorage, _projectId, length, _contributorLimit, _maxContribution, _minContribution, _rewards);

        setPendingContributionTiersLength(_fundingStorage, _projectId, length + 1);
    }

    // TimelineProposal

    function setTimelineProposalTimestamp(address _fundingStorage, uint _projectId, uint _timestamp) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)), _timestamp);
    }

    function setTimelineProposalApprovalCount(address _fundingStorage, uint _projectId, uint _count) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)), _count);
    }

    function setTimelineProposalDisapprovalCount(address _fundingStorage, uint _projectId, uint _count) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)), _count);
    }

    function setTimelineProposalIsActive(address _fundingStorage, uint _projectId, bool _isActive) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)), _isActive);
    }

    function setTimelineProposalHasFailed(address _fundingStorage, uint _projectId, bool _hasFailed) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)), _hasFailed);
    }

    function setTimelineProposalHasVoted(address _fundingStorage, uint _projectId, address _address, bool _hasVoted) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)), _hasVoted);
    }

    function setTimelineProposal(
        address _fundingStorage,
        uint _projectId,
        uint _timestamp,
        uint _approvalCount,
        uint _disapprovalCount,
        bool _isActive,
        bool _hasFailed
    )
    internal
    {
        setTimelineProposalTimestamp(_fundingStorage, _projectId, _timestamp);
        setTimelineProposalApprovalCount(_fundingStorage, _projectId, _approvalCount);
        setTimelineProposalDisapprovalCount(_fundingStorage, _projectId, _disapprovalCount);
        setTimelineProposalIsActive(_fundingStorage, _projectId, _isActive);
        setTimelineProposalHasFailed(_fundingStorage, _projectId, _hasFailed);
    }

    // MilestoneCompletionSubmission

    function setMilestoneCompletionSubmissionTimestamp(address _fundingStorage, uint _projectId, uint _timestamp) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)), _timestamp);
    }

    function setMilestoneCompletionSubmissionApprovalCount(address _fundingStorage, uint _projectId, uint _count) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionDisapprovalCount(address _fundingStorage, uint _projectId, uint _count) internal {
        return FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionReport(address _fundingStorage, uint _projectId, string _report) internal {
        return FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)), _report);
    }

    function setMilestoneCompletionSubmissionIsActive(address _fundingStorage, uint _projectId, bool _isActive) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)), _isActive);
    }

    function setMilestoneCompletionSubmissionHasFailed(address _fundingStorage, uint _projectId, bool _hasFailed) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)), _hasFailed);
    }

    function setMilestoneCompletionSubmissionHasVoted(address _fundingStorage, uint _projectId, address _address, bool _vote) internal {
        return FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)), _vote);
    }

    function setMilestoneCompletionSubmission(
        address _fundingStorage,
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
        setMilestoneCompletionSubmissionTimestamp(_fundingStorage, _projectId, _timestamp);
        setMilestoneCompletionSubmissionApprovalCount(_fundingStorage, _projectId, _approvalCount);
        setMilestoneCompletionSubmissionDisapprovalCount(_fundingStorage, _projectId, _disapprovalCount);
        setMilestoneCompletionSubmissionReport(_fundingStorage, _projectId, _report);
        setMilestoneCompletionSubmissionIsActive(_fundingStorage, _projectId, _isActive);
        setMilestoneCompletionSubmissionHasFailed(_fundingStorage, _projectId, _hasFailed);
    }
}
