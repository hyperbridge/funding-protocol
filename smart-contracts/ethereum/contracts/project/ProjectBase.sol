pragma solidity ^0.4.24;

import "../libraries/storage/ProjectStorageAccess.sol";
import "../libraries/storage/DeveloperStorageAccess.sol";
import "../libraries/storage/ContributionStorageAccess.sol";

contract ProjectBase {

    using ProjectStorageAccess for address;
    using DeveloperStorageAccess for address;
    using ContributionStorageAccess for address;

    modifier onlyProjectDeveloper(uint _projectId) {
        require(msg.sender == fundingStorage.getProjectDeveloper(_projectId), "You must be the project developer to perform this action.");
        _;
    }

    modifier onlyProjectContributor(uint _projectId) {
        uint contributorId = fundingStorage.getContributorId(msg.sender);
        require(contributorId != 0, "This address is not a contributor.");
        require(fundingStorage.getContributesToProject(contributorId, _projectId), "This address is not a contributor to this project.");
        _;
    }

    modifier onlyDraftProject(uint _projectId) {
        require(Status(fundingStorage.getProjectStatus(_projectId)) == Status.Draft, "This action can only be performed on a draft project.");
        _;
    }

    modifier onlyPublishedProject(uint _projectId) {
        require(Status(fundingStorage.getProjectStatus(_projectId)) == Status.Published, "This action can only be performed on a published project.");
        _;
    }
    enum Status {Draft, Pending, Published, Removed, Rejected}

    address fundingStorage;
}
