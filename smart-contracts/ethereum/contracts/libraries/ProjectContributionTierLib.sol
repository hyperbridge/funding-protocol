pragma solidity ^0.4.24;

import "../ProjectEternalStorage.sol";
import "./ProjectStorageAccess.sol";

library ProjectContributionTierLib {

    using ProjectStorageAccess for address;

    function addTier(address _pStorage, uint _projectId, uint _contributorLimit, uint _maxContribution, uint _minContribution, string _rewards) external {
        uint currentLength = _pStorage.getPendingContributionTiersLength(_projectId);

        _pStorage.setPendingContributionTier(_projectId, currentLength, _contributorLimit, _maxContribution, _minContribution, _rewards);

        _pStorage.setPendingContributionTiersLength(_projectId, currentLength + 1);
    }

    function finalizeTiers(address _pStorage, uint _projectId) external {

        _pStorage.deleteContributionTiers(_projectId);

        uint length = _pStorage.getPendingContributionTiersLength(_projectId);

        for (uint i = 0; i < length; i++) {
            ProjectStorageAccess.ContributionTier memory tier = _pStorage._getPendingContributionTier(_projectId, i);

            _pStorage.setContributionTier(_projectId, i, tier.contributorLimit, tier.minContribution, tier.maxContribution, tier.rewards);
        }

        _pStorage.setContributionTiersLength(_projectId, length);

        _pStorage.deletePendingContributionTiers(_projectId);
    }
}
