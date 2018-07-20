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

    function () public payable {
        revert();
    }

    function initialize(address _fundingStorage) external {
        fundingStorage = _fundingStorage;
        require(FundingStorage(fundingStorage).getContractIsValid(this), "This contract is not registered in FundingStorage.");

        // reserve developerId 0
        fundingStorage.incrementNextDeveloperId();
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
            uint[] ownedProjectIds
        )
    {
        DeveloperStorageAccess.Developer memory developer = fundingStorage.getDeveloper(_id);
        return (_id, developer.addr, developer.name, developer.ownedProjectIds);
    }
}