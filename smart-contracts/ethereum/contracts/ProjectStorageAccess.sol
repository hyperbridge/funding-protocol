pragma solidity ^0.4.24;

import "./ProjectStorage.sol";

contract ProjectStorageAccess {

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

    ProjectStorage pStorage;

    // Getters

    function getNextId() internal view returns (uint) {
        return pStorage.getUint(keccak256("project.nextId"));
    }

    function getStatus(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.status", _projectId)));
    }

    function getTitle(uint _projectId) internal view returns (string) {
        return pStorage.getString(keccak256(abi.encodePacked("project.title", _projectId)));
    }

    function getDescription(uint _projectId) internal view returns (string) {
        return pStorage.getString(keccak256(abi.encodePacked("project.description", _projectId)));
    }

    function getAbout(uint _projectId) internal view returns (string) {
        return pStorage.getString(keccak256(abi.encodePacked("project.title", _projectId)));
    }

    function getDeveloper(uint _projectId) internal view returns (address) {
        return pStorage.getAddress(keccak256(abi.encodePacked("project.developer", _projectId)));
    }

    function getDeveloperId(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.developerId", _projectId)));
    }

    function getContributionGoal(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)));
    }

    function getNoRefunds(uint _projectId) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)));
    }

    function getNoTimeline(uint _projectId) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)));
    }

    function getActiveMilestoneIndex(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)));
    }

    // Timeline

    function getTimelineIsActive(uint _projectId) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.timeline.isActive", _projectId)));
    }

    function getTimelineLength(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)));
    }

    function getPendingTimelineLength(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)));
    }

    function getTimelineHistoryLength(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)));
    }

    // Milestone

    function getMilestoneTitle(uint _projectId, uint _index) internal view returns (string) {
        return pStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
    }

    function getMilestoneDescription(uint _projectId, uint _index) internal view returns (string) {
        return pStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
    }

    function getMilestonePercentage(uint _projectId, uint _index) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
    }

    function getMilestoneIsComplete(uint _projectId, uint _index) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));
    }

    // ContributionTier

    function getContributionTiersLength(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)));
    }

    function getContributionTierContributorLimit(uint _projectId, uint _index) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
    }

    function getContributionTierMinContribution(uint _projectId, uint _index) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
    }

    function getContributionTierMaxContribution(uint _projectId, uint _index) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
    }

    function getContributionTierRewards(uint _projectId, uint _index) internal view returns (string) {
        return pStorage.getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));
    }

    function getContributionTier(uint _projectId, uint _index) internal view returns (ContributionTier) {
        uint contributorLimit = getContributionTierContributorLimit(_projectId, _index);
        uint minContribution = getContributionTierMinContribution(_projectId, _index);
        uint maxContribution = getContributionTierMaxContribution(_projectId, _index);
        string memory rewards = getContributionTierRewards(_projectId, _index);

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    function getPendingContributionTiersLength(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)));
    }

    function getPendingContributionTierContributorLimit(uint _projectId, uint _index) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
    }

    function getPendingContributionTierMinContribution(uint _projectId, uint _index) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
    }

    function getPendingContributionTierMaxContribution(uint _projectId, uint _index) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
    }

    function getPendingContributionTierRewards(uint _projectId, uint _index) internal view returns (string) {
        return pStorage.getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));
    }

    function getPendingContributionTier(uint _projectId, uint _index) internal view returns (ContributionTier) {
        uint contributorLimit = getPendingContributionTierContributorLimit(_projectId, _index);
        uint minContribution = getPendingContributionTierMinContribution(_projectId, _index);
        uint maxContribution = getPendingContributionTierMaxContribution(_projectId, _index);
        string memory rewards = getPendingContributionTierRewards(_projectId, _index);

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    // TimelineProposal

    function getTimelineProposalTimestamp(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
    }

    function getTimelineProposalApprovalCount(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
    }

    function getTimelineProposalDisapprovalCount(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
    }

    function getTimelineProposalIsActive(uint _projectId) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
    }

    function getTimelineProposalHasFailed(uint _projectId) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));
    }

    function getTimelineProposalHasVoted(uint _projectId, address _address) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)));
    }

    function getTimelineProposal(uint _projectId) internal view returns (TimelineProposal) {
        uint timestamp = getTimelineProposalTimestamp(_projectId);
        uint approvalCount = getTimelineProposalApprovalCount(_projectId);
        uint disapprovalCount = getTimelineProposalDisapprovalCount(_projectId);
        bool isActive = getTimelineProposalIsActive(_projectId);
        bool hasFailed = getTimelineProposalHasFailed(_projectId);

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

    function getMilestoneCompletionSubmissionTimestamp(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
    }

    function getMilestoneCompletionSubmissionApprovalCount(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionDisapprovalCount(uint _projectId) internal view returns (uint) {
        return pStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionReport(uint _projectId) internal view returns (string) {
        return pStorage.getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
    }

    function getMilestoneCompletionSubmissionIsActive(uint _projectId) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasFailed(uint _projectId) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasVoted(uint _projectId, address _address) internal view returns (bool) {
        return pStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)));
    }

    function getMilestoneCompletionSubmission(uint _projectId) internal view returns (MilestoneCompletionSubmission) {
        uint timestamp = getMilestoneCompletionSubmissionTimestamp(_projectId);
        uint approvalCount = getMilestoneCompletionSubmissionApprovalCount(_projectId);
        uint disapprovalCount = getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
        string memory report = getMilestoneCompletionSubmissionReport(_projectId);
        bool isActive = getMilestoneCompletionSubmissionIsActive(_projectId);
        bool hasFailed = getMilestoneCompletionSubmissionHasFailed(_projectId);

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

    function incrementNextId() internal {
        uint currentId = getNextId();
        pStorage.setUint(keccak256("project.nextId"), currentId + 1);
    }

    function setStatus(uint _projectId, uint _status) internal {
        pStorage.setUint(keccak256(abi.encodePacked("project.status", _projectId)), _status);
    }

    function setTitle(uint _projectId, string _title) internal {
        pStorage.setString(keccak256(abi.encodePacked("project.title", _projectId)), _title);
    }

    function setDescription(uint _projectId, string _description) internal {
        pStorage.setString(keccak256(abi.encodePacked("project.description", _projectId)), _description);
    }

    function setAbout(uint _projectId, string _about) internal {
        pStorage.setString(keccak256(abi.encodePacked("project.about", _projectId)), _about);
    }

    function setDeveloper(uint _projectId, address _developer) internal {
        pStorage.setAddress(keccak256(abi.encodePacked("project.developer", _projectId)), _developer);
    }

    function setDeveloperId(uint _projectId, uint _developerId) internal {
        pStorage.setUint(keccak256(abi.encodePacked("project.developerId", _projectId)), _developerId);
    }

    function setContributionGoal(uint _projectId, uint _goal) internal {
        pStorage.setUint(keccak256(abi.encodePacked("project.contributionGoal", _projectId)), _goal);
    }

    function setNoRefunds(uint _projectId, bool _noRefunds) internal {
        pStorage.setBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)), _noRefunds);
    }

    function setNoTimeline(uint _projectId, bool _noTimeline) internal {
        pStorage.setBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)), _noTimeline);
    }

    function setActiveMilestoneIndex(uint _projectId, uint _index) internal {
        pStorage.setUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)), _index);
    }

    // Timeline

    function setTimelineIsActive(uint _projectId, bool _isActive) internal {
        return pStorage.setBool(keccak256(abi.encodePacked("project.timeline.isActive", _projectId)), _isActive);
    }

    function setTimelineLength(uint _projectId, uint _length) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)), _length);
    }

    function setPendingTimelineLength(uint _projectId, uint _length) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)), _length);
    }

    function setTimelineHistoryLength(uint _projectId, uint _length) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)), _length);
    }

    // Milestone

    function setMilestoneTitle(uint _projectId, uint _index, string _title) internal {
        return pStorage.setString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)), _title);
    }

    function setMilestoneDescription(uint _projectId, uint _index, string _description) internal {
        return pStorage.setString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)), _description);
    }

    function setMilestonePercentage(uint _projectId, uint _index, uint _percentage) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function setMilestoneIsComplete(uint _projectId, uint _index, bool _isComplete) internal {
        return pStorage.setBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    // ContributionTier

    function setContributionTiersLength(uint _projectId, uint _length) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)), _length);
    }

    function setContributionTierContributorLimit(uint _projectId, uint _index, uint _limit) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setContributionTierMinContribution(uint _projectId, uint _index, uint _min) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setContributionTierMaxContribution(uint _projectId, uint _index, uint _max) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setContributionTierRewards(uint _projectId, uint _index, string _rewards) internal {
        pStorage.setString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setContributionTier(
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _minContribution,
        uint _maxContribution,
        string _rewards
    )
    internal
    {
        setContributionTierContributorLimit(_projectId, _index, _contributorLimit);
        setContributionTierMinContribution(_projectId, _index, _minContribution);
        setContributionTierMaxContribution(_projectId, _index, _maxContribution);
        setContributionTierRewards(_projectId, _index, _rewards);
    }

    function setPendingContributionTiersLength(uint _projectId, uint _length) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)), _length);
    }

    function setPendingContributionTierContributorLimit(uint _projectId, uint _index, uint _limit) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setPendingContributionTierMinContribution(uint _projectId, uint _index, uint _min) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setPendingContributionTierMaxContribution(uint _projectId, uint _index, uint _max) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setPendingContributionTierRewards(uint _projectId, uint _index, string _rewards) internal {
        pStorage.setString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setPendingContributionTier(
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _minContribution,
        uint _maxContribution,
        string _rewards
    )
    internal
    {
        setPendingContributionTierContributorLimit(_projectId, _index, _contributorLimit);
        setPendingContributionTierMinContribution(_projectId, _index, _minContribution);
        setPendingContributionTierMaxContribution(_projectId, _index, _maxContribution);
        setPendingContributionTierRewards(_projectId, _index, _rewards);
    }

    // TimelineProposal

    function setTimelineProposalTimestamp(uint _projectId, uint _timestamp) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)), _timestamp);
    }

    function setTimelineProposalApprovalCount(uint _projectId, uint _count) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)), _count);
    }

    function setTimelineProposalDisapprovalCount(uint _projectId, uint _count) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)), _count);
    }

    function setTimelineProposalIsActive(uint _projectId, bool _isActive) internal {
        return pStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)), _isActive);
    }

    function setTimelineProposalHasFailed(uint _projectId, bool _hasFailed) internal {
        return pStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)), _hasFailed);
    }

    function setTimelineProposalHasVoted(uint _projectId, address _address, bool _vote) internal {
        return pStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)), _vote);
    }

    function setTimelineProposal(
        uint _projectId,
        uint _timestamp,
        uint _approvalCount,
        uint _disapprovalCount,
        bool _isActive,
        bool _hasFailed
    )
    internal
    {
        setTimelineProposalTimestamp(_projectId, _timestamp);
        setTimelineProposalApprovalCount(_projectId, _approvalCount);
        setTimelineProposalDisapprovalCount(_projectId, _disapprovalCount);
        setTimelineProposalIsActive(_projectId, _isActive);
        setTimelineProposalHasFailed(_projectId, _hasFailed);
    }

    // MilestoneCompletionSubmission

    function setMilestoneCompletionSubmissionTimestamp(uint _projectId, uint _timestamp) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)), _timestamp);
    }

    function setMilestoneCompletionSubmissionApprovalCount(uint _projectId, uint _count) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionDisapprovalCount(uint _projectId, uint _count) internal {
        return pStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionReport(uint _projectId, string _report) internal {
        return pStorage.setString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)), _report);
    }

    function setMilestoneCompletionSubmissionIsActive(uint _projectId, bool _isActive) internal {
        return pStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)), _isActive);
    }

    function setMilestoneCompletionSubmissionHasFailed(uint _projectId, bool _hasFailed) internal {
        return pStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)), _hasFailed);
    }

    function setMilestoneCompletionSubmissionHasVoted(uint _projectId, address _address, bool _vote) internal {
        return pStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)), _vote);
    }

    function setMilestoneCompletionSubmission(
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
        setMilestoneCompletionSubmissionTimestamp(_projectId, _timestamp);
        setMilestoneCompletionSubmissionApprovalCount(_projectId, _approvalCount);
        setMilestoneCompletionSubmissionDisapprovalCount(_projectId, _disapprovalCount);
        setMilestoneCompletionSubmissionReport(_projectId, _report);
        setMilestoneCompletionSubmissionIsActive(_projectId, _isActive);
        setMilestoneCompletionSubmissionHasFailed(_projectId, _hasFailed);
    }

    // Miscellaneous

    function setProject(
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
        setStatus(_projectId, _status);
        setTitle(_projectId, _title);
        setDescription(_projectId, _description);
        setAbout(_projectId, _about);
        setDeveloper(_projectId, _developer);
        setDeveloperId(_projectId, _developerId);
        setContributionGoal(_projectId, _contributionGoal);
    }
}
