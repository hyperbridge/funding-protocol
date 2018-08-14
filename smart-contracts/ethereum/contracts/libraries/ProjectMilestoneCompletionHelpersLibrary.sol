pragma solidity ^0.4.24;

import "./storage/ProjectStorageAccess.sol";
import "./storage/ContributionStorageAccess.sol";
import "../FundingVault.sol";
import "../FundingStorage.sol";

library ProjectMilestoneCompletionHelpersLibrary {

    using ProjectStorageAccess for FundingStorage;
    using ContributionStorageAccess for FundingStorage;

    function releaseMilestoneFunds(FundingStorage _fundingStorage, uint _projectId, uint _index) internal {
        uint fundsRaised = _fundingStorage.getProjectFundsRaised(_projectId);
        uint percentageToSend = _fundingStorage.getTimelineMilestonePercentage(_projectId, _index);
        uint amountToSend = fundsRaised * percentageToSend / 100;
        address developer = _fundingStorage.getProjectDeveloper(_projectId);
        FundingVault fv = FundingVault(_fundingStorage.getContractAddress("FundingVault"));
        fv.withdrawEth(amountToSend, developer);
    }
}
