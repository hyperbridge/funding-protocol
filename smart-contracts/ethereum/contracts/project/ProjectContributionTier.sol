pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";

contract ProjectContributionTier is ProjectBase {

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;
    }

    function addContributionTier(
        uint _projectId,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
        external
        onlyProjectDeveloper(_projectId)
        onlyDraftProject(_projectId)
    {
        uint currentLength = fundingStorage.getPendingContributionTiersLength(_projectId);

        fundingStorage.setPendingContributionTier(_projectId, currentLength, _contributorLimit, _maxContribution, _minContribution, _rewards);

        fundingStorage.setPendingContributionTiersLength(_projectId, currentLength + 1);
    }

    function editContributionTier(
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
        external
        onlyProjectDeveloper(_projectId)
        onlyDraftProject(_projectId)
    {
        fundingStorage.setPendingContributionTier(_projectId, _index, _contributorLimit, _maxContribution, _minContribution, _rewards);
    }

    function clearPendingContributionTiers(uint _projectId) external {
        fundingStorage.setPendingContributionTiersLength(_projectId, 0);
    }

    function getPendingContributionTier(uint _projectId, uint _index) external view returns (uint _contributorLimit, uint _maxContribution, uint _minContribution, string _rewards) {
        ProjectStorageAccess.ContributionTier memory tier = fundingStorage.getPendingContributionTier(_projectId, _index);

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
    }

    function getContributionTier(uint _projectId, uint _index) external view returns (uint _contributorLimit, uint _maxContribution, uint _minContribution, string _rewards) {
        ProjectStorageAccess.ContributionTier memory tier = fundingStorage.getContributionTier(_projectId, _index);

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
    }
}
