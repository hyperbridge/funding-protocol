pragma solidity ^0.4.24;

import "./storage/ProjectStorageAccess.sol";
import "./storage/ContributionStorageAccess.sol";
import "../FundingVault.sol";
import "../FundingStorage.sol";

library ProjectMilestoneCompletionHelpersLibrary {

    using SafeMath for uint256;
    using ProjectStorageAccess for address;
    using ContributionStorageAccess for address;

    function releaseMilestoneFunds(address _fundingStorage, uint _projectId, uint _index) internal {
        uint fundsRaised = _fundingStorage.getProjectFundsRaised(_projectId);
        uint percentageToSend = _fundingStorage.getTimelineMilestonePercentage(_projectId, _index);
        uint amountToSend = fundsRaised.mul(percentageToSend).div(100);
        address developer = _fundingStorage.getProjectDeveloper(_projectId);
        FundingStorage fs = FundingStorage(_fundingStorage);
        FundingVault fv = FundingVault(fs.getContractAddress("FundingVault"));
        fv.withdrawEth(amountToSend, developer);
    }
}
