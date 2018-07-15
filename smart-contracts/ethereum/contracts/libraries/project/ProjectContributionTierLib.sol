pragma solidity ^0.4.24;

import "../storage/ProjectStorageAccess.sol";

library ProjectContributionTierLib {

    using ProjectStorageAccess for address;

    function addTier(address _fundingStorage, uint _projectId, uint _contributorLimit, uint _maxContribution, uint _minContribution, string _rewards) external {
        uint currentLength = _fundingStorage.getPendingContributionTiersLength(_projectId);

        _fundingStorage.setPendingContributionTier(_projectId, currentLength, _contributorLimit, _maxContribution, _minContribution, _rewards);

        _fundingStorage.setPendingContributionTiersLength(_projectId, currentLength + 1);
    }

    function finalizeTiers(address _fundingStorage, uint _projectId) external {

        _fundingStorage.deleteContributionTiers(_projectId);

        uint length = _fundingStorage.getPendingContributionTiersLength(_projectId);

        for (uint i = 0; i < length; i++) {
            ProjectStorageAccess.ContributionTier memory tier = _fundingStorage._getPendingContributionTier(_projectId, i);

            _fundingStorage.setContributionTier(_projectId, i, tier.contributorLimit, tier.minContribution, tier.maxContribution, tier.rewards);
        }

        _fundingStorage.setContributionTiersLength(_projectId, length);

        _fundingStorage.deletePendingContributionTiers(_projectId);
    }
}
