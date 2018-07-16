pragma solidity ^0.4.24;

import "./libraries/storage/ContributionStorageAccess.sol";
import "./libraries/storage/ProjectStorageAccess.sol";
import "./FundingVault.sol";

contract Contribution {

    using ContributionStorageAccess for address;
    using ProjectStorageAccess for address;

    address public fundingStorage;

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;

        // reserve contributorId 0
        fundingStorage.incrementNextContributorId();
    }

    function () public payable {
        revert();
    }

    function contributeToProject(uint _projectId) external payable {
        require(fundingStorage.getProjectIsActive(_projectId), "Project does not exist."); // check that project exists

        uint contributorId = fundingStorage.getContributorId(msg.sender);

        // if contributor doesn't exist, create it
        if (contributorId == 0) {
            contributorId = fundingStorage.generateNewContributorId();

            fundingStorage.setContributorId(msg.sender, contributorId);
            fundingStorage.setContributorAddress(contributorId, msg.sender);
        }

        // if project is not in contributor's project list, add it
        if (!fundingStorage.getContributesToProject(contributorId, _projectId)) {
            fundingStorage.setContributesToProject(contributorId, _projectId, true);
            uint index = fundingStorage.getContributorFundedProjectsLength(contributorId);
            fundingStorage.setContributorFundedProject(contributorId, index, _projectId);
            fundingStorage.setContributorFundedProjectsLength(contributorId, index + 1);
        }

        // add to projectContributorList, if not already present
        if (fundingStorage.getContributionAmount(_projectId, contributorId) == 0) {
            uint length = fundingStorage.getProjectContributorListLength(_projectId);
            fundingStorage.setProjectContributor(_projectId, length, contributorId);
            fundingStorage.setProjectContributorListLength(_projectId, length + 1);
        }

        // add contribution amount to project
        uint currentAmount = fundingStorage.getContributionAmount(_projectId, contributorId);
        fundingStorage.setContributionAmount(_projectId, contributorId, currentAmount + msg.value);

        FundingStorage fs = FundingStorage(fundingStorage);
        FundingVault fv = FundingVault(fs.getAddress(keccak256(abi.encodePacked("contract.address", "FundingVault"))));
        fv.depositEth.value(msg.value)();
    }
}
