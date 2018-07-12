pragma solidity ^0.4.24;

import "./libraries/storage/ContributionStorageAccess.sol";

contract Contribution {

    using ContributionStorageAccess for address;

    modifier fundingServiceOnly() {
        require(msg.sender == fundingService, "This action can only be performed by the Funding Service.");
        _;
    }

    modifier validFundingContractOnly() {
        // TODO
        _;
    }

    address public fundingService;
    address public fundingStorage;

    constructor(address _fundingService, address _fundingStorage) public {
        fundingService = _fundingService;
        fundingStorage = _fundingStorage;

        // reserve contributorId 0
        fundingStorage.incrementNextId();
    }

    function () public payable {
        revert();
    }

    function contributeToProject(uint _projectId, address _contributor) external payable fundingServiceOnly {
//        (bool isActive, uint status, string memory title, string memory description, string memory about, uint contributionGoal, address developer, uint developerId) = Project(projectContract).getProject(_projectId);
//
//        require(isActive, "Project does not exist."); // check that project exists

        uint contributorId = fundingStorage.getContributorId(_contributor);

        // if contributor doesn't exist, create it
        if (contributorId == 0) {
            contributorId = fundingStorage.generateNewId();

            fundingStorage.setContributorId(_contributor, contributorId);
            fundingStorage.setAddress(contributorId, _contributor);
        }

        // if project is not in contributor's project list, add it
        if (!fundingStorage.getContributesToProject(contributorId, _projectId)) {
            fundingStorage.setContributesToProject(contributorId, _projectId, true);
            uint index = fundingStorage.getFundedProjectsLength(contributorId);
            fundingStorage.setFundedProject(contributorId, index, _projectId);
            fundingStorage.setFundedProjectsLength(contributorId, index + 1);
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

        // TODO - money to project
    }
}
