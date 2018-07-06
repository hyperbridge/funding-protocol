pragma solidity ^0.4.24;

import "./ProjectStorage.sol";

contract ProjectStorageAccess is ProjectStorage {

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

    // _getters

    function _getNextId() internal view returns (uint) {
        return _getUint(keccak256("project.nextId"));
    }

    function _getStatus(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.status", _projectId)));
    }

    function _getTitle(uint _projectId) internal view returns (string) {
        return _getString(keccak256(abi.encodePacked("project.title", _projectId)));
    }

    function _getDescription(uint _projectId) internal view returns (string) {
        return _getString(keccak256(abi.encodePacked("project.description", _projectId)));
    }

    function _getAbout(uint _projectId) internal view returns (string) {
        return _getString(keccak256(abi.encodePacked("project.title", _projectId)));
    }

    function _getDeveloper(uint _projectId) internal view returns (address) {
        return _getAddress(keccak256(abi.encodePacked("project.developer", _projectId)));
    }

    function _getDeveloperId(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.developerId", _projectId)));
    }

    function _getContributionGoal(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)));
    }

    function _getNoRefunds(uint _projectId) internal view returns (bool) {
        return _getBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)));
    }

    function _getNoTimeline(uint _projectId) internal view returns (bool) {
        return _getBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)));
    }

    function _getActiveMilestoneIndex(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)));
    }

    // Timeline

    function _getTimelineIsActive(uint _projectId) internal view returns (bool) {
        return _getBool(keccak256(abi.encodePacked("project.timeline.isActive", _projectId)));
    }

    function _getTimelineLength(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)));
    }

    function _getPendingTimelineLength(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)));
    }

    function _getTimelineHistoryLength(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)));
    }

    // Milestone

    function _getTimelineMilestoneTitle(uint _projectId, uint _index) internal view returns (string) {
        require(_index < _getTimelineLength(_projectId), "Index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
    }

    function _getTimelineMilestoneDescription(uint _projectId, uint _index) internal view returns (string) {
        require(_index < _getTimelineLength(_projectId), "Index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
    }

    function _getTimelineMilestonePercentage(uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _getTimelineLength(_projectId), "Index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
    }

    function _getTimelineMilestoneIsComplete(uint _projectId, uint _index) internal view returns (bool) {
        require(_index < _getTimelineLength(_projectId), "Index is outside of accessible range.");

        return _getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));
    }

    function _getTimelineMilestone(uint _projectId, uint _index) internal view returns (string memory title, string memory description, uint percentage, bool isComplete) {
        require(_index < _getTimelineLength(_projectId), "Index is outside of accessible range.");

        title = _getTimelineMilestoneTitle(_projectId, _index);
        description = _getTimelineMilestoneDescription(_projectId, _index);
        percentage = _getTimelineMilestonePercentage(_projectId, _index);
        isComplete = _getTimelineMilestoneIsComplete(_projectId, _index);

        return (title, description, percentage, isComplete);
    }

    function _getTimelineMilestone(uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < _getTimelineLength(_projectId), "Index is outside of accessible range.");

        string memory title = _getTimelineMilestoneTitle(_projectId, _index);
        string memory description = _getTimelineMilestoneDescription(_projectId, _index);
        uint percentage = _getTimelineMilestonePercentage(_projectId, _index);
        bool isComplete = _getTimelineMilestoneIsComplete(_projectId, _index);

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function _getPendingTimelineMilestoneTitle(uint _projectId, uint _index) internal view returns (string) {
        require(_index < _getPendingTimelineLength(_projectId), "Index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
    }

    function _getPendingTimelineMilestoneDescription(uint _projectId, uint _index) internal view returns (string) {
        require(_index < _getPendingTimelineLength(_projectId), "Index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
    }

    function _getPendingTimelineMilestonePercentage(uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _getPendingTimelineLength(_projectId), "Index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
    }

    function _getPendingTimelineMilestoneIsComplete(uint _projectId, uint _index) internal view returns (bool) {
        require(_index < _getPendingTimelineLength(_projectId), "Index is outside of accessible range.");

        return _getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));
    }

    function _getPendingTimelineMilestone(uint _projectId, uint _index) internal view returns (string memory title, string memory description, uint percentage, bool isComplete) {
        require(_index < _getPendingTimelineLength(_projectId), "Index is outside of accessible range.");

        title = _getPendingTimelineMilestoneTitle(_projectId, _index);
        description = _getPendingTimelineMilestoneDescription(_projectId, _index);
        percentage = _getPendingTimelineMilestonePercentage(_projectId, _index);
        isComplete = _getPendingTimelineMilestoneIsComplete(_projectId, _index);

        return (title, description, percentage, isComplete);
    }

    function _getPendingTimelineMilestone(uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < _getPendingTimelineLength(_projectId), "Index is outside of accessible range.");

        string memory title = _getPendingTimelineMilestoneTitle(_projectId, _index);
        string memory description = _getPendingTimelineMilestoneDescription(_projectId, _index);
        uint percentage = _getPendingTimelineMilestonePercentage(_projectId, _index);
        bool isComplete = _getPendingTimelineMilestoneIsComplete(_projectId, _index);

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function _getCompletedMilestonesLength(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)));
    }

    function _getCompletedMilestoneTitle(uint _projectId, uint _index) internal view returns (string) {
        require(_index < _getCompletedMilestonesLength(_projectId), "Index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
    }

    function _getCompletedMilestoneDescription(uint _projectId, uint _index) internal view returns (string) {
        require(_index < _getCompletedMilestonesLength(_projectId), "Index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
    }

    function _getCompletedMilestonePercentage(uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _getCompletedMilestonesLength(_projectId), "Index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
    }

    function _getCompletedMilestoneIsComplete(uint _projectId, uint _index) internal view returns (bool) {
        require(_index < _getCompletedMilestonesLength(_projectId), "Index is outside of accessible range.");

        return _getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));
    }

    function _getCompletedMilestone(uint _projectId, uint _index) internal view returns (string memory title, string memory description, uint percentage, bool isComplete) {
        require(_index < _getCompletedMilestonesLength(_projectId), "Index is outside of accessible range.");

        title = _getCompletedMilestoneTitle(_projectId, _index);
        description = _getCompletedMilestoneDescription(_projectId, _index);
        percentage = _getCompletedMilestonePercentage(_projectId, _index);
        isComplete = _getCompletedMilestoneIsComplete(_projectId, _index);

        return (title, description, percentage, isComplete);
    }

    function _getCompletedMilestone(uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < _getCompletedMilestonesLength(_projectId), "Index is outside of accessible range.");

        string memory title = _getCompletedMilestoneTitle(_projectId, _index);
        string memory description = _getCompletedMilestoneDescription(_projectId, _index);
        uint percentage = _getCompletedMilestonePercentage(_projectId, _index);
        bool isComplete = _getCompletedMilestoneIsComplete(_projectId, _index);

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function _getTimelineHistoryMilestonesLength(uint _projectId, uint _timelineIndex) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)));
    }

    function _getTimelineHistoryMilestoneTitle(uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < _getTimelineHistoryLength(_projectId), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _getTimelineHistoryMilestonesLength(_projectId, _timelineIndex), "Milestone index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function _getTimelineHistoryMilestoneDescription(uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < _getTimelineHistoryLength(_projectId), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _getTimelineHistoryMilestonesLength(_projectId, _timelineIndex), "Milestone index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function _getTimelineHistoryMilestonePercentage(uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (uint) {
        require(_timelineIndex < _getTimelineHistoryLength(_projectId), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _getTimelineHistoryMilestonesLength(_projectId, _timelineIndex), "Milestone index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function _getTimelineHistoryMilestoneIsComplete(uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (bool) {
        require(_timelineIndex < _getTimelineHistoryLength(_projectId), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _getTimelineHistoryMilestonesLength(_projectId, _timelineIndex), "Milestone index is outside of accessible range.");

        return _getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function _getTimelineHistoryMilestone(uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string memory title, string memory description, uint percentage, bool isComplete) {
        require(_timelineIndex < _getTimelineHistoryLength(_projectId), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _getTimelineHistoryMilestonesLength(_projectId, _timelineIndex), "Milestone index is outside of accessible range.");

        title = _getTimelineHistoryMilestoneTitle(_projectId, _timelineIndex, _milestoneIndex);
        description = _getTimelineHistoryMilestoneDescription(_projectId, _timelineIndex, _milestoneIndex);
        percentage = _getTimelineHistoryMilestonePercentage(_projectId, _timelineIndex, _milestoneIndex);
        isComplete = _getTimelineHistoryMilestoneIsComplete(_projectId, _timelineIndex, _milestoneIndex);

        return (title, description, percentage, isComplete);
    }

    function _getTimelineHistoryMilestone(uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (Milestone) {
        require(_timelineIndex < _getTimelineHistoryLength(_projectId), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _getTimelineHistoryMilestonesLength(_projectId, _timelineIndex), "Milestone index is outside of accessible range.");

        string memory title = _getTimelineHistoryMilestoneTitle(_projectId, _timelineIndex, _milestoneIndex);
        string memory description = _getTimelineHistoryMilestoneDescription(_projectId, _timelineIndex, _milestoneIndex);
        uint percentage = _getTimelineHistoryMilestonePercentage(_projectId, _timelineIndex, _milestoneIndex);
        bool isComplete = _getTimelineHistoryMilestoneIsComplete(_projectId, _timelineIndex, _milestoneIndex);

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    // ContributionTier

    function _getContributionTiersLength(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)));
    }

    function _getContributionTierContributorLimit(uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _getContributionTiersLength(_projectId), "Index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
    }

    function _getContributionTierMinContribution(uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _getContributionTiersLength(_projectId), "Index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
    }

    function _getContributionTierMaxContribution(uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _getContributionTiersLength(_projectId), "Index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
    }

    function _getContributionTierRewards(uint _projectId, uint _index) internal view returns (string) {
        require(_index < _getContributionTiersLength(_projectId), "Index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));
    }

    function _getContributionTier(uint _projectId, uint _index) internal view returns (uint contributorLimit, uint minContribution, uint maxContribution, string rewards) {
        require(_index < _getContributionTiersLength(_projectId), "Index is outside of accessible range.");

        contributorLimit = _getContributionTierContributorLimit(_projectId, _index);
        minContribution = _getContributionTierMinContribution(_projectId, _index);
        maxContribution = _getContributionTierMaxContribution(_projectId, _index);
        rewards = _getContributionTierRewards(_projectId, _index);

        return (contributorLimit, minContribution, maxContribution, rewards);
    }

    function _getContributionTier(uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < _getContributionTiersLength(_projectId), "Index is outside of accessible range.");

        uint contributorLimit = _getContributionTierContributorLimit(_projectId, _index);
        uint minContribution = _getContributionTierMinContribution(_projectId, _index);
        uint maxContribution = _getContributionTierMaxContribution(_projectId, _index);
        string memory rewards = _getContributionTierRewards(_projectId, _index);

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    function _getPendingContributionTiersLength(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)));
    }

    function _getPendingContributionTierContributorLimit(uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _getPendingContributionTiersLength(_projectId), "Index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
    }

    function _getPendingContributionTierMinContribution(uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _getPendingContributionTiersLength(_projectId), "Index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
    }

    function _getPendingContributionTierMaxContribution(uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _getPendingContributionTiersLength(_projectId), "Index is outside of accessible range.");

        return _getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
    }

    function _getPendingContributionTierRewards(uint _projectId, uint _index) internal view returns (string) {
        require(_index < _getPendingContributionTiersLength(_projectId), "Index is outside of accessible range.");

        return _getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));
    }

    function _getPendingContributionTier(uint _projectId, uint _index) internal view returns (uint contributorLimit, uint minContribution, uint maxContribution, string rewards) {
        require(_index < _getPendingContributionTiersLength(_projectId), "Index is outside of accessible range.");

        contributorLimit = _getPendingContributionTierContributorLimit(_projectId, _index);
        minContribution = _getPendingContributionTierMinContribution(_projectId, _index);
        maxContribution = _getPendingContributionTierMaxContribution(_projectId, _index);
        rewards = _getPendingContributionTierRewards(_projectId, _index);

        return (contributorLimit, minContribution, maxContribution, rewards);
    }

    function _getPendingContributionTier(uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < _getPendingContributionTiersLength(_projectId), "Index is outside of accessible range.");

        uint contributorLimit = _getPendingContributionTierContributorLimit(_projectId, _index);
        uint minContribution = _getPendingContributionTierMinContribution(_projectId, _index);
        uint maxContribution = _getPendingContributionTierMaxContribution(_projectId, _index);
        string memory rewards = _getPendingContributionTierRewards(_projectId, _index);

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    // TimelineProposal

    function _getTimelineProposalTimestamp(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
    }

    function _getTimelineProposalApprovalCount(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
    }

    function _getTimelineProposalDisapprovalCount(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
    }

    function _getTimelineProposalIsActive(uint _projectId) internal view returns (bool) {
        return _getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
    }

    function _getTimelineProposalHasFailed(uint _projectId) internal view returns (bool) {
        return _getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));
    }

    function _getTimelineProposalHasVoted(uint _projectId, address _address) internal view returns (bool) {
        return _getBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)));
    }

    function _getTimelineProposal(uint _projectId) internal view returns (uint timestamp, uint approvalCount, uint disapprovalCount, bool isActive, bool hasFailed) {
        timestamp = _getTimelineProposalTimestamp(_projectId);
        approvalCount = _getTimelineProposalApprovalCount(_projectId);
        disapprovalCount = _getTimelineProposalDisapprovalCount(_projectId);
        isActive = _getTimelineProposalIsActive(_projectId);
        hasFailed = _getTimelineProposalHasFailed(_projectId);

        return (timestamp, approvalCount, disapprovalCount, isActive, hasFailed);
    }


    function _getTimelineProposal(uint _projectId) internal view returns (TimelineProposal) {
        uint timestamp = _getTimelineProposalTimestamp(_projectId);
        uint approvalCount = _getTimelineProposalApprovalCount(_projectId);
        uint disapprovalCount = _getTimelineProposalDisapprovalCount(_projectId);
        bool isActive = _getTimelineProposalIsActive(_projectId);
        bool hasFailed = _getTimelineProposalHasFailed(_projectId);

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

    function _getMilestoneCompletionSubmissionTimestamp(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
    }

    function _getMilestoneCompletionSubmissionApprovalCount(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
    }

    function _getMilestoneCompletionSubmissionDisapprovalCount(uint _projectId) internal view returns (uint) {
        return _getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
    }

    function _getMilestoneCompletionSubmissionReport(uint _projectId) internal view returns (string) {
        return _getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
    }

    function _getMilestoneCompletionSubmissionIsActive(uint _projectId) internal view returns (bool) {
        return _getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
    }

    function _getMilestoneCompletionSubmissionHasFailed(uint _projectId) internal view returns (bool) {
        return _getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));
    }

    function _getMilestoneCompletionSubmissionHasVoted(uint _projectId, address _address) internal view returns (bool) {
        return _getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)));
    }

    function _getMilestoneCompletionSubmission(uint _projectId) internal view returns (uint timestamp, uint approvalCount, uint disapprovalCount, string report, bool isActive, bool hasFailed) {
        timestamp = _getMilestoneCompletionSubmissionTimestamp(_projectId);
        approvalCount = _getMilestoneCompletionSubmissionApprovalCount(_projectId);
        disapprovalCount = _getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
        report = _getMilestoneCompletionSubmissionReport(_projectId);
        isActive = _getMilestoneCompletionSubmissionIsActive(_projectId);
        hasFailed = _getMilestoneCompletionSubmissionHasFailed(_projectId);

        return (timestamp, approvalCount, disapprovalCount, report, isActive, hasFailed);
    }

    function _getMilestoneCompletionSubmission(uint _projectId) internal view returns (MilestoneCompletionSubmission) {
        uint timestamp = _getMilestoneCompletionSubmissionTimestamp(_projectId);
        uint approvalCount = _getMilestoneCompletionSubmissionApprovalCount(_projectId);
        uint disapprovalCount = _getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
        string memory report = _getMilestoneCompletionSubmissionReport(_projectId);
        bool isActive = _getMilestoneCompletionSubmissionIsActive(_projectId);
        bool hasFailed = _getMilestoneCompletionSubmissionHasFailed(_projectId);

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



    // Setters

    function _incrementNextId() internal {
        uint currentId = _getNextId();
        setUint(keccak256("project.nextId"), currentId + 1);
    }

    function _setStatus(uint _projectId, uint _status) internal {
        setUint(keccak256(abi.encodePacked("project.status", _projectId)), _status);
    }

    function _setTitle(uint _projectId, string _title) internal {
        setString(keccak256(abi.encodePacked("project.title", _projectId)), _title);
    }

    function _setDescription(uint _projectId, string _description) internal {
        setString(keccak256(abi.encodePacked("project.description", _projectId)), _description);
    }

    function _setAbout(uint _projectId, string _about) internal {
        setString(keccak256(abi.encodePacked("project.about", _projectId)), _about);
    }

    function _setDeveloper(uint _projectId, address _developer) internal {
        setAddress(keccak256(abi.encodePacked("project.developer", _projectId)), _developer);
    }

    function _setDeveloperId(uint _projectId, uint _developerId) internal {
        setUint(keccak256(abi.encodePacked("project.developerId", _projectId)), _developerId);
    }

    function _setContributionGoal(uint _projectId, uint _goal) internal {
        setUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)), _goal);
    }

    function _setNoRefunds(uint _projectId, bool _noRefunds) internal {
        setBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)), _noRefunds);
    }

    function _setNoTimeline(uint _projectId, bool _noTimeline) internal {
        setBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)), _noTimeline);
    }

    function _setActiveMilestoneIndex(uint _projectId, uint _index) internal {
        setUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)), _index);
    }

    // Timeline

    function _setTimelineIsActive(uint _projectId, bool _isActive) internal {
        return setBool(keccak256(abi.encodePacked("project.timeline.isActive", _projectId)), _isActive);
    }

    function _setTimelineLength(uint _projectId, uint _length) internal {
        return setUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)), _length);
    }

    function _setPendingTimelineLength(uint _projectId, uint _length) internal {
        return setUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)), _length);
    }

    function _setTimelineHistoryLength(uint _projectId, uint _length) internal {
        return setUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)), _length);
    }

    // Milestone

    function _setTimelineMilestoneTitle(uint _projectId, uint _index, string _title) internal {
        return setString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)), _title);
    }

    function _setTimelineMilestoneDescription(uint _projectId, uint _index, string _description) internal {
        return setString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)), _description);
    }

    function _setTimelineMilestonePercentage(uint _projectId, uint _index, uint _percentage) internal {
        return setUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function _setTimelineMilestoneIsComplete(uint _projectId, uint _index, bool _isComplete) internal {
        return setBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function _setTimelineMilestone(
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        _setTimelineMilestoneTitle(_projectId, _index, _title);
        _setTimelineMilestoneDescription(_projectId, _index, _description);
        _setTimelineMilestonePercentage(_projectId, _index, _percentage);
        _setTimelineMilestoneIsComplete(_projectId, _index, _isComplete);
    }

    function _setPendingTimelineMilestoneTitle(uint _projectId, uint _index, string _title) internal {
        return setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)), _title);
    }

    function _setPendingTimelineMilestoneDescription(uint _projectId, uint _index, string _description) internal {
        return setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)), _description);
    }

    function _setPendingTimelineMilestonePercentage(uint _projectId, uint _index, uint _percentage) internal {
        return setUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function _setPendingTimelineMilestoneIsComplete(uint _projectId, uint _index, bool _isComplete) internal {
        return setBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function _setPendingTimelineMilestone(
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        _setPendingTimelineMilestoneTitle(_projectId, _index, _title);
        _setPendingTimelineMilestoneDescription(_projectId, _index, _description);
        _setPendingTimelineMilestonePercentage(_projectId, _index, _percentage);
        _setPendingTimelineMilestoneIsComplete(_projectId, _index, _isComplete);
    }

    function _setCompletedMilestonesLength(uint _projectId, uint _length) internal {
        return setUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)), _length);
    }

    function _setCompletedMilestoneTitle(uint _projectId, uint _index, string _title) internal {
        return setString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)), _title);
    }

    function _setCompletedMilestoneDescription(uint _projectId, uint _index, string _description) internal {
        return setString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)), _description);
    }

    function _setCompletedMilestonePercentage(uint _projectId, uint _index, uint _percentage) internal {
        return setUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)), _percentage);
    }

    function _setCompletedMilestoneIsComplete(uint _projectId, uint _index, bool _isComplete) internal {
        return setBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)), _isComplete);
    }

    function _setCompletedMilestone(
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        _setCompletedMilestoneTitle(_projectId, _index, _title);
        _setCompletedMilestoneDescription(_projectId, _index, _description);
        _setCompletedMilestonePercentage(_projectId, _index, _percentage);
        _setCompletedMilestoneIsComplete(_projectId, _index, _isComplete);
    }

    function _setTimelineHistoryMilestonesLength(uint _projectId, uint _timelineIndex, uint _length) internal {
        return setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)), _length);
    }

    function _setTimelineHistoryMilestoneTitle(uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _title) internal {
        return setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _projectId, _timelineIndex, _milestoneIndex)), _title);
    }

    function _setTimelineHistoryMilestoneDescription(uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _description) internal {
        return setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _projectId, _timelineIndex, _milestoneIndex)), _description);
    }

    function _setTimelineHistoryMilestonePercentage(uint _projectId, uint _timelineIndex, uint _milestoneIndex, uint _percentage) internal {
        return setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _projectId, _timelineIndex, _milestoneIndex)), _percentage);
    }

    function _setTimelineHistoryMilestoneIsComplete(uint _projectId, uint _timelineIndex, uint _milestoneIndex, bool _isComplete) internal {
        return setBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _projectId, _timelineIndex, _milestoneIndex)), _isComplete);
    }

    function _setTimelineHistoryMilestone(
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
        _setTimelineHistoryMilestoneTitle(_projectId, _timelineIndex, _milestoneIndex, _title);
        _setTimelineHistoryMilestoneDescription(_projectId, _timelineIndex, _milestoneIndex, _description);
        _setTimelineHistoryMilestonePercentage(_projectId, _timelineIndex, _milestoneIndex, _percentage);
        _setTimelineHistoryMilestoneIsComplete(_projectId, _timelineIndex, _milestoneIndex, _isComplete);
    }



    // ContributionTier

    function _setContributionTiersLength(uint _projectId, uint _length) internal {
        return setUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)), _length);
    }

    function _setContributionTierContributorLimit(uint _projectId, uint _index, uint _limit) internal {
        return setUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function _setContributionTierMinContribution(uint _projectId, uint _index, uint _min) internal {
        return setUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)), _min);
    }

    function _setContributionTierMaxContribution(uint _projectId, uint _index, uint _max) internal {
        return setUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function _setContributionTierRewards(uint _projectId, uint _index, string _rewards) internal {
        setString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function _setContributionTier(
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _minContribution,
        uint _maxContribution,
        string _rewards
    )
    internal
    {
        _setContributionTierContributorLimit(_projectId, _index, _contributorLimit);
        _setContributionTierMinContribution(_projectId, _index, _minContribution);
        _setContributionTierMaxContribution(_projectId, _index, _maxContribution);
        _setContributionTierRewards(_projectId, _index, _rewards);
    }

    function _setPendingContributionTiersLength(uint _projectId, uint _length) internal {
        return setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)), _length);
    }

    function _setPendingContributionTierContributorLimit(uint _projectId, uint _index, uint _limit) internal {
        return setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function _setPendingContributionTierMinContribution(uint _projectId, uint _index, uint _min) internal {
        return setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)), _min);
    }

    function _setPendingContributionTierMaxContribution(uint _projectId, uint _index, uint _max) internal {
        return setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function _setPendingContributionTierRewards(uint _projectId, uint _index, string _rewards) internal {
        setString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function _setPendingContributionTier(
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _minContribution,
        uint _maxContribution,
        string _rewards
    )
    internal
    {
        _setPendingContributionTierContributorLimit(_projectId, _index, _contributorLimit);
        _setPendingContributionTierMinContribution(_projectId, _index, _minContribution);
        _setPendingContributionTierMaxContribution(_projectId, _index, _maxContribution);
        _setPendingContributionTierRewards(_projectId, _index, _rewards);
    }

    // TimelineProposal

    function _setTimelineProposalTimestamp(uint _projectId, uint _timestamp) internal {
        return setUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)), _timestamp);
    }

    function _setTimelineProposalApprovalCount(uint _projectId, uint _count) internal {
        return setUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)), _count);
    }

    function _setTimelineProposalDisapprovalCount(uint _projectId, uint _count) internal {
        return setUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)), _count);
    }

    function _setTimelineProposalIsActive(uint _projectId, bool _isActive) internal {
        return setBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)), _isActive);
    }

    function _setTimelineProposalHasFailed(uint _projectId, bool _hasFailed) internal {
        return setBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)), _hasFailed);
    }

    function _setTimelineProposalHasVoted(uint _projectId, address _address, bool _vote) internal {
        return setBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)), _vote);
    }

    function _setTimelineProposal(
        uint _projectId,
        uint _timestamp,
        uint _approvalCount,
        uint _disapprovalCount,
        bool _isActive,
        bool _hasFailed
    )
    internal
    {
        _setTimelineProposalTimestamp(_projectId, _timestamp);
        _setTimelineProposalApprovalCount(_projectId, _approvalCount);
        _setTimelineProposalDisapprovalCount(_projectId, _disapprovalCount);
        _setTimelineProposalIsActive(_projectId, _isActive);
        _setTimelineProposalHasFailed(_projectId, _hasFailed);
    }

    // MilestoneCompletionSubmission

    function _setMilestoneCompletionSubmissionTimestamp(uint _projectId, uint _timestamp) internal {
        return setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)), _timestamp);
    }

    function _setMilestoneCompletionSubmissionApprovalCount(uint _projectId, uint _count) internal {
        return setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)), _count);
    }

    function _setMilestoneCompletionSubmissionDisapprovalCount(uint _projectId, uint _count) internal {
        return setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)), _count);
    }

    function _setMilestoneCompletionSubmissionReport(uint _projectId, string _report) internal {
        return setString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)), _report);
    }

    function _setMilestoneCompletionSubmissionIsActive(uint _projectId, bool _isActive) internal {
        return setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)), _isActive);
    }

    function _setMilestoneCompletionSubmissionHasFailed(uint _projectId, bool _hasFailed) internal {
        return setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)), _hasFailed);
    }

    function _setMilestoneCompletionSubmissionHasVoted(uint _projectId, address _address, bool _vote) internal {
        return setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)), _vote);
    }

    function _setMilestoneCompletionSubmission(
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
        _setMilestoneCompletionSubmissionTimestamp(_projectId, _timestamp);
        _setMilestoneCompletionSubmissionApprovalCount(_projectId, _approvalCount);
        _setMilestoneCompletionSubmissionDisapprovalCount(_projectId, _disapprovalCount);
        _setMilestoneCompletionSubmissionReport(_projectId, _report);
        _setMilestoneCompletionSubmissionIsActive(_projectId, _isActive);
        _setMilestoneCompletionSubmissionHasFailed(_projectId, _hasFailed);
    }

    // Miscellaneous

    function _setProject(
        uint _projectId,
        uint _status,
        string _title,
        string _description,
        string _about,
        address _developer,
        uint _developerId,
        uint _contributionGoal
    )
    internal
    {
        _setStatus(_projectId, _status);
        _setTitle(_projectId, _title);
        _setDescription(_projectId, _description);
        _setAbout(_projectId, _about);
        _setDeveloper(_projectId, _developer);
        _setDeveloperId(_projectId, _developerId);
        _setContributionGoal(_projectId, _contributionGoal);
    }



    // Deletion

    function _deleteContributionTiers(uint _projectId) internal {
        uint length = _getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            deleteUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", i, _projectId)));
            deleteUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", i, _projectId)));
            deleteUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", i, _projectId)));
            deleteString(keccak256(abi.encodePacked("project.contributionTiers.rewards", i, _projectId)));
        }

        _setContributionTiersLength(_projectId, 0);
    }

    function _deletePendingContributionTiers(uint _projectId) internal {
        uint length = _getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            deleteUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", i, _projectId)));
            deleteUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", i, _projectId)));
            deleteUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", i, _projectId)));
            deleteString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", i, _projectId)));
        }

        _setPendingContributionTiersLength(_projectId, 0);
    }

    function _deleteTimeline(uint _projectId) internal {
        uint length = _getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            deleteString(keccak256(abi.encodePacked("project.timeline.milestones.title", i, _projectId)));
            deleteString(keccak256(abi.encodePacked("project.timeline.milestones.description", i, _projectId)));
            deleteUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", i, _projectId)));
            deleteBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", i, _projectId)));
        }

        _setTimelineLength(_projectId, 0);
    }

    function _deletePendingTimeline(uint _projectId) internal {
        uint length = _getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)));

        for (uint i = 0; i < length; i++) {
            deleteString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", i, _projectId)));
            deleteString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", i, _projectId)));
            deleteUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", i, _projectId)));
            deleteBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", i, _projectId)));
        }

        _setPendingTimelineLength(_projectId, 0);
    }
}
