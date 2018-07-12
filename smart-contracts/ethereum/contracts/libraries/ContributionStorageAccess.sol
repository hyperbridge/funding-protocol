pragma solidity ^0.4.24;

import "../FundingStorage.sol";

library ContributionStorageAccess {

    struct Contributor {
        uint id;
        address addr;
        mapping(uint => bool) contributesToProject;
        uint[] fundedProjects;
    }

    /*
        Each contributor (indexed by id) stores the following data in FundingStorage and accesses it through the
        associated namespace:
            uint id                                                                         (contributor.id)
            address addr                                                                    (contributor.addr)
            mapping(uint => bool) contributesToProject                                      (contributor.contributesToProject)
            uint[] fundedProjects                                                           (contributor.fundedProjects)

        The FundingStorage tracks contribution amounts:
            mapping(uint (projID) => mapping (address => uint)) projectContributionAmount   (contribution.projectContributionAmount)
            mapping(uint => address[]) projectContributorList                               (contribution.projectContributorList)

        There is a registry of contributors:
            mapping(address => uint (id)) contributorMap                                    (contribution.contributorMap)
    */

    // Getters

    function generateNewId(address _fundingStorage) internal view returns (uint) {
        uint id = getNextId(_fundingStorage);
        incrementNextId(_fundingStorage);
        return id;
    }

    function getNextId(address _fundingStorage) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256("contributor.nextId"));
    }

    function getContributorId(address _fundingStorage, address _contributorAddress) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("contribution.contributorMap", _contributorAddress)));
    }

    function getAddress(address _fundingStorage, uint _contributorId) internal view returns (address) {
        return FundingStorage(_fundingStorage).getAddress(keccak256(abi.encodePacked("contributor.addr", _contributorId)));
    }

    function getContributesToProject(address _fundingStorage, uint _contributorId, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("contributor.contributesToProject", _contributorId, _projectId)));
    }

    function getFundedProjectsLength(address _fundingStorage, uint _contributorId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("contributor.fundedProjects.length", _contributorId)));
    }

    function getFundedProject(address _fundingStorage, uint _contributorId, uint _index) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("contributor.fundedProjects", _index, _contributorId)));
    }

    function getFundedProjectIds(address _fundingStorage, uint _contributorId) internal view returns (uint[]) {
        uint length = getFundedProjectsLength(_fundingStorage, _contributorId);

        uint[] fundedIds;

        for (uint i = 0; i < length; i++) {
            fundedIds.push(getFundedProject(_fundingStorage, _contributorId, i));
        }

        return fundedIds;
    }

    function getContributor(address _fundingStorage, uint _contributorId) internal view returns (Contributor) {
        require(getAddress(_fundingStorage, _contributorId) != address(0), "Contributor does not exist."); // check that contributor exists

        Contributor memory contributor = Contributor({
            id: _contributorId,
            addr: getAddress(_fundingStorage, _contributorId),
            fundedProjects: getFundedProjects(_fundingStorage, _contributorId)
            });

        return contributor;
    }

    // Setters



}
