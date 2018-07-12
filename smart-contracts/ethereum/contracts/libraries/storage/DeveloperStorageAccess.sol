pragma solidity ^0.4.24;

import "../FundingStorage.sol";

library DeveloperStorageAccess {

    struct Developer {
        uint id;
        address addr;
        string name;
        uint reputation;
        mapping(uint => bool) ownsProject; // project id => owned by this dev
        uint[] ownedProjectIds; // the projects belonging to this developer
    }

    /*
        Each developer (indexed by ID) stores the following data in FundingStorage and accesses it through the
        associated namespace:
            address addr                                                    (developer.addr)
            string name                                                     (developer.name)
            uint reputation                                                 (developer.reputation)
            mapping(uint (id) => bool) ownsProject                          (developer.ownsProject)
            uint[] ownedProjectIds                                          (developer.projectIds)

        In addition, there is a registry of developers:
            mapping(address => uint (id)) developerMap                      (developer.developerMap)
    */

    // Getters

    function generateNewId(address _fundingStorage) internal view returns (uint) {
        uint id = getNextId(_fundingStorage);
        incrementNextId(_fundingStorage);
        return id;
    }

    function getNextId(address _fundingStorage) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256("developer.nextId"));
    }

    function getDeveloperId(address _fundingStorage, address _developerAddress) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("developer.developerMap", _developerAddress)));
    }

    function getReputation(address _fundingStorage, uint _developerId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("developer.reputation", _developerId)));
    }

    function getAddress(address _fundingStorage, uint _developerId) internal view returns (address) {
        return FundingStorage(_fundingStorage).getAddress(keccak256(abi.encodePacked("developer.address", _developerId)));
    }

    function getName(address _fundingStorage, uint _developerId) internal view returns (string) {
        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("developer.name", _developerId)));
    }

    function getOwnsProject(address _fundingStorage, uint _developerId, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("developer.ownsProject", _developerId, _projectId)));
    }

    function getOwnedProjectIdsLength(address _fundingStorage, uint _developerId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("developer.projectIds.length", _developerId)));
    }

    function getOwnedProjectId(address _fundingStorage, uint _developerId, uint _index) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("developer.projectIds", _index, _developerId)));
    }

    function getOwnedProjectIds(address _fundingStorage, uint _developerId) internal view returns (uint[]) {
        uint length = getOwnedProjectIdsLength(_fundingStorage, _developerId);

        uint[] ownedIds;

        for (uint i = 0; i < length; i++) {
            ownedIds.push(getOwnedProjectId(_fundingStorage, _developerId, i));
        }

        return ownedIds;
    }

    function getDeveloper(address _fundingStorage, uint _developerId) internal view returns (Developer) {
        require(getAddress(_fundingStorage, _developerId) != address(0), "Developer does not exist."); // check that developer exists

        Developer memory developer = Developer({
            id: _developerId,
            addr: getAddress(_fundingStorage, _developerId),
            name: getName(_fundingStorage, _developerId),
            reputation: getReputation(_fundingStorage, _developerId),
            ownedProjectIds: getOwnedProjectIds(_fundingStorage, _developerId)
        });

        return developer;
    }



    // Setters

    function incrementNextId(address _fundingStorage) internal {
        uint currentId = FundingStorage(_fundingStorage).getUint(keccak256("developer.nextId"));
        FundingStorage(_fundingStorage).setUint(keccak256("developer.nextId"), currentId + 1);
    }

    function setDeveloperId(address _fundingStorage, address _developerAddress, uint _developerId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("developer.developerMap", _developerAddress)), _developerId);
    }

    function setReputation(address _fundingStorage, uint _developerId, uint _rep) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("developer.reputation", _developerId)), _rep);
    }

    function setAddress(address _fundingStorage, uint _developerId, address _address) internal {
        FundingStorage(_fundingStorage).setAddress(keccak256(abi.encodePacked("developer.address", _developerId)), _address);
    }

    function setName(address _fundingStorage, uint _developerId, string _name) internal {
        FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("developer.name", _developerId)), _name);
    }

    function setOwnsProject(address _fundingStorage, uint _developerId, uint _projectId, bool _ownsProject) internal {
        FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("developer.ownsProject", _developerId, _projectId)), _ownsProject);
    }

    function setOwnedProjectIdsLength(address _fundingStorage, uint _developerId, uint _length) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("developer.projectIds.length", _developerId)), _length);
    }

    function setOwnedProjectId(address _fundingStorage, uint _developerId, uint _index, uint _projectId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("developer.projectIds", _index, _developerId)), _projectId);
    }
}
