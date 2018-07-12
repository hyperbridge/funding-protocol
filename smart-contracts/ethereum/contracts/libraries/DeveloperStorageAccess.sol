pragma solidity ^0.4.24;

import "../FundingStorage.sol";

library DeveloperStorageAccess {

    struct Developer {
        uint id;
        uint reputation;
        address addr;
        string name;
        mapping(uint => bool) ownsProject; // project id => owned by this dev
        uint[] ownedProjectIds; // the projects belonging to this developer
    }

    /*
        Each developer stores the following data in FundingStorage and accesses it through the associated namespace:
            uint id                                                         (developer.id)
            uint reputation                                                 (developer.reputation)
            address addr                                                    (developer.addr)
            string name                                                     (developer.name)
            mapping(uint => bool) ownsProject                               (developer.ownsProject)
            uint[] ownedProjectIds                                          (developer.projectIds)
    */

    // Getters

    function getNextId(address _pStorage) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256("developer.nextId"));
    }

    function getReputation(address _pStorage, uint _developerId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("developer.reputation", _developerId)));
    }

    function getName(address _pStorage, uint _developerId) internal view returns (string) {
        return FundingStorage(_pStorage).getString(keccak256(abi.encodePacked("developer.name", _developerId)));
    }

    function getOwnsProject(address _pStorage, uint _developerId, uint _projectId) internal view returns (bool) {
        return FundingStorage(_pStorage).getBool(keccak256(abi.encodePacked("developer.ownsProject", _developerId, _projectId)));
    }

    function getOwnedProjectIdsLength(address _pStorage, uint _developerId) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("developer.projectIds.length", _developerId)));
    }

    function getOwnedProjectId(address _pStorage, uint _developerId, uint _index) internal view returns (uint) {
        return FundingStorage(_pStorage).getUint(keccak256(abi.encodePacked("developer.projectIds", _index, _developerId)));
    }



    // Setters

    function incrementNextId(address _pStorage) internal {
        uint currentId = FundingStorage(_pStorage).getUint(keccak256("developer.nextId"));
        FundingStorage(_pStorage).setUint(keccak256("developer.nextId"), currentId + 1);
    }

    function setReputation(address _pStorage, uint _developerId, uint _rep) internal {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("developer.reputation", _developerId)), _rep);
    }

    function setName(address _pStorage, uint _developerId, string _name) internal {
        FundingStorage(_pStorage).setString(keccak256(abi.encodePacked("developer.name", _developerId)), _name);
    }

    function setOwnsProject(address _pStorage, uint _developerId, uint _projectId, bool _ownsProject) internal {
        FundingStorage(_pStorage).setBool(keccak256(abi.encodePacked("developer.ownsProject", _developerId, _projectId)), _ownsProject);
    }

    function setOwnedProjectIdsLength(address _pStorage, uint _developerId, uint _length) internal {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("developer.projectIds.length", _developerId)), _length);
    }

    function setOwnedProjectId(address _pStorage, uint _developerId, uint _index, uint _projectId) internal {
        FundingStorage(_pStorage).setUint(keccak256(abi.encodePacked("developer.projectIds", _index, _developerId)), _projectId);
    }
}
