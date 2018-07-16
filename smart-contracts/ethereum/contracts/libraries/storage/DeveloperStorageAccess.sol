pragma solidity ^0.4.24;

import "../../FundingStorage.sol";

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

    function generateNewDeveloperId(address _fundingStorage) internal view returns (uint) {
        uint id = getNextDeveloperId(_fundingStorage);
        incrementNextDeveloperId(_fundingStorage);
        return id;
    }

    function getNextDeveloperId(address _fundingStorage) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256("developer.nextId"));
    }

    function getDeveloperId(address _fundingStorage, address _developerAddress) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("developer.developerMap", _developerAddress)));
    }

    function getDeveloperReputation(address _fundingStorage, uint _developerId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("developer.reputation", _developerId)));
    }

    function getDeveloperAddress(address _fundingStorage, uint _developerId) internal view returns (address) {
        return FundingStorage(_fundingStorage).getAddress(keccak256(abi.encodePacked("developer.address", _developerId)));
    }

    function getDeveloperName(address _fundingStorage, uint _developerId) internal view returns (string) {
        return FundingStorage(_fundingStorage).getString(keccak256(abi.encodePacked("developer.name", _developerId)));
    }

    function getDeveloperOwnsProject(address _fundingStorage, uint _developerId, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("developer.ownsProject", _developerId, _projectId)));
    }

    function getDeveloperOwnedProjectsLength(address _fundingStorage, uint _developerId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("developer.projectIds.length", _developerId)));
    }

    function getDeveloperOwnedProject(address _fundingStorage, uint _developerId, uint _index) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("developer.projectIds", _index, _developerId)));
    }

    function getDeveloperOwnedProjects(address _fundingStorage, uint _developerId) internal view returns (uint[]) {
        uint length = getDeveloperOwnedProjectsLength(_fundingStorage, _developerId);

        uint[] memory ownedIds = new uint[](length);

        for (uint i = 0; i < length; i++) {
            ownedIds[i] = getDeveloperOwnedProject(_fundingStorage, _developerId, i);
        }

        return ownedIds;
    }

    function getDeveloper(address _fundingStorage, uint _developerId) internal view returns (Developer) {
        require(getDeveloperAddress(_fundingStorage, _developerId) != address(0), "Developer does not exist."); // check that developer exists

        Developer memory developer = Developer({
            id: _developerId,
            addr: getDeveloperAddress(_fundingStorage, _developerId),
            name: getDeveloperName(_fundingStorage, _developerId),
            reputation: getDeveloperReputation(_fundingStorage, _developerId),
            ownedProjectIds: getDeveloperOwnedProjects(_fundingStorage, _developerId)
        });

        return developer;
    }



    // Setters

    function incrementNextDeveloperId(address _fundingStorage) internal {
        uint currentId = FundingStorage(_fundingStorage).getUint(keccak256("developer.nextId"));
        FundingStorage(_fundingStorage).setUint(keccak256("developer.nextId"), currentId + 1);
    }

    function setDeveloperId(address _fundingStorage, address _developerAddress, uint _developerId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("developer.developerMap", _developerAddress)), _developerId);
    }

    function setDeveloperReputation(address _fundingStorage, uint _developerId, uint _rep) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("developer.reputation", _developerId)), _rep);
    }

    function setDeveloperAddress(address _fundingStorage, uint _developerId, address _address) internal {
        FundingStorage(_fundingStorage).setAddress(keccak256(abi.encodePacked("developer.address", _developerId)), _address);
    }

    function setDeveloperName(address _fundingStorage, uint _developerId, string _name) internal {
        FundingStorage(_fundingStorage).setString(keccak256(abi.encodePacked("developer.name", _developerId)), _name);
    }

    function setDeveloperOwnsProject(address _fundingStorage, uint _developerId, uint _projectId, bool _ownsProject) internal {
        FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("developer.ownsProject", _developerId, _projectId)), _ownsProject);
    }

    function setDeveloperOwnedProjectsLength(address _fundingStorage, uint _developerId, uint _length) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("developer.projectIds.length", _developerId)), _length);
    }

    function setDeveloperOwnedProject(address _fundingStorage, uint _developerId, uint _index, uint _projectId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("developer.projectIds", _index, _developerId)), _projectId);
    }
}
