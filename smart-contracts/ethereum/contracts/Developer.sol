pragma solidity ^0.4.24;

import "./libraries/storage/DeveloperStorageAccess.sol";

contract Developer {

    using DeveloperStorageAccess for address;

    modifier onlyLatestFundingContract() {
        require(FundingStorage(fundingStorage).getBool(keccak256(abi.encodePacked("contract.address", msg.sender))));
        _;
    }

    address public fundingStorage;

    event DeveloperCreated(address developerAddress, uint developerId);

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;

        // reserve developerId 0
        fundingStorage.incrementNextDeveloperId();
    }

    function () public payable {
        revert();
    }

    function createDeveloper(string _name) external {
        require(fundingStorage.getDeveloperId(msg.sender) == 0, "This account is already a developer.");

        // Get next ID from storage + increment next ID
        uint id = fundingStorage.generateNewDeveloperId();

        // Create developer
        fundingStorage.setDeveloperId(msg.sender, id);
        fundingStorage.setDeveloperName(id, _name);
        fundingStorage.setDeveloperAddress(id, msg.sender);

        emit DeveloperCreated(msg.sender, id);
    }

    function getDeveloper(uint _id) external view
        returns (
            uint id,
            address addr,
            string name,
            uint reputation,
            uint[] ownedProjectIds
        )
    {
        DeveloperStorageAccess.Developer memory developer = fundingStorage.getDeveloper(_id);
        return (_id, developer.addr, developer.name, developer.reputation, developer.ownedProjectIds);
    }

    function updateDeveloperReputation(uint _developerId, uint _val) external onlyLatestFundingContract {
        uint currentRep = fundingStorage.getDeveloperReputation(_developerId);
        fundingStorage.setDeveloperReputation(_developerId, currentRep + _val);
    }
}