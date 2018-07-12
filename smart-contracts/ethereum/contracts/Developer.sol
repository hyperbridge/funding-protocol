pragma solidity ^0.4.24;

import "./libraries/storage/DeveloperStorageAccess.sol";

contract Developer {

    using DeveloperStorageAccess for address;

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

    event DeveloperCreated(uint developerId);

    constructor(address _fundingService, address _fundingStorage) public {
        fundingService = _fundingService;
        fundingStorage = _fundingStorage;

        // reserve developerId 0
        fundingStorage.incrementNextId();
    }

    function () public payable {
        revert();
    }

    function createDeveloper(string _name, address _devAddress) external fundingServiceOnly {
        require(fundingStorage.getDeveloperId(_address) == 0, "This account is already a developer.");

        // Get next ID from storage + increment next ID
        uint id = fundingStorage.generateNewId();

        // Create developer
        fundingStorage.setDeveloperId(msg.sender, id);
        fundingStorage.setName(id, _name);
        fundingStorage.setAddress(id, msg.sender);

        emit DeveloperCreated(id);
    }

    function getDeveloper(uint _id) external view fundingServiceOnly
        returns (
            uint id,
            address addr,
            string name,
            uint reputation,
            uint[] ownedProjectIds
        )
    {
        DeveloperStorageAccess.Developer memory developer = pStorage.getDeveloper(_id);
        return (_id, developer.addr, developer.name, developer.reputation, developer.ownedProjectIds);
    }

    function updateDeveloperReputation(uint _developerId, uint _val) validFundingContractOnly {
        uint currentRep = fundingStorage.getReputation(_developerId);
        fundingStorage.setReputation(_developerId, currentRep + _val);
    }
}