pragma solidity ^0.4.24;

import "./project/ProjectBase.sol";
import "./libraries/storage/CurationStorageAccess.sol";
import "./libraries/storage/ProjectStorageAccess.sol";

contract Curation is Ownable {

    using CurationStorageAccess for address;
    using ProjectStorageAccess for address;

    modifier onlyCurator() {
        require(fundingStorage.getCuratorId(msg.sender) != 0, "You must be a curator to perform this action.");
        _;
    }

    modifier onlyDeveloper(uint _projectId) {
        require(fundingStorage.getProjectDeveloper(_projectId) == msg.sender, "You must be the project developer to perform this action.");
        _;
    }

    address public fundingStorage;

    event CuratorCreated(address curatorAddress, uint curatorId);

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;
    }
    
    function () public payable {
        revert();
    }

    function initialize(address _fundingStorage) external {
        fundingStorage = _fundingStorage;
        require(FundingStorage(fundingStorage).getContractIsValid(this), "This contract is not registered in FundingStorage.");

        // reserve curatorId 0
        fundingStorage.incrementNextCuratorId();
    }

    function createCurator() external {
        require(fundingStorage.getCuratorId(msg.sender) == 0, "This account is already a curator.");

        // Get next ID from storage + increment next ID
        uint id = fundingStorage.generateNewCuratorId();

        // Create developer
        fundingStorage.setCuratorId(msg.sender, id);

        emit CuratorCreated(msg.sender, id);
    }

    function curate(uint _projectId, bool _isApproved) public onlyCurator {
        require(fundingStorage.getProjectStatus(_projectId) == uint(ProjectBase.Status.Pending), "This project is not seeking curator approval at this time.");
        require(fundingStorage.getDraftCurationIsActive(_projectId), "This project is not open for curation.");

        uint currentApprovalCount = fundingStorage.getDraftCurationApprovalCount(_projectId);

        if (_isApproved) {
            fundingStorage.setDraftCurationApprovalCount(_projectId, currentApprovalCount + 1);
        } else {
            fundingStorage.setDraftCurationApprovalCount(_projectId, currentApprovalCount - 1);
        }
    }

    function publishProject(uint _projectId) public onlyDeveloper(_projectId) {
        require(fundingStorage.getDraftCurationIsActive(_projectId), "This project is not open for curation.");
        require(now < fundingStorage.getDraftCurationTimestamp(_projectId) + 4 weeks, "The project curation window has not closed.");

        uint approvalCount = fundingStorage.getDraftCurationApprovalCount(_projectId);
        uint curationThreshold = fundingStorage.getCurationThreshold();

        if (approvalCount >= curationThreshold) {
            fundingStorage.setProjectStatus(_projectId, uint(ProjectBase.Status.Published));
        } else {
            fundingStorage.setProjectStatus(_projectId, uint(ProjectBase.Status.Rejected));
        }
    }

    function getCurationThreshold() external view returns (uint threshold) {
        threshold = fundingStorage.getCurationThreshold();
    }

    function setCurationThreshold(uint _threshold) external onlyOwner {
        fundingStorage.setCurationThreshold(_threshold);
    }
}