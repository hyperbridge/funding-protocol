pragma solidity ^0.4.24;

import "../../FundingStorage.sol";

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
            uint id                                                                     (contributor.id)
            address addr                                                                (contributor.addr)
            mapping(uint => bool) contributesToProject                                  (contributor.contributesToProject)
            uint[] fundedProjects                                                       (contributor.fundedProjects)

        The FundingStorage tracks contribution amounts:
            mapping(uint (projID) => mapping (uint (id) => uint)) contributionAmount    (contribution.contributionAmount)
            mapping(uint (projID) => address[]) contributorList                         (contribution.contributorList)

        There is a registry of contributors:
            mapping(address => uint (id)) contributorMap                                (contribution.contributorMap)
    */

    // Getters

    function generateNewContributorId(address _fundingStorage) internal view returns (uint) {
        uint id = getNextContributorId(_fundingStorage);
        incrementNextContributorId(_fundingStorage);
        return id;
    }

    function getNextContributorId(address _fundingStorage) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256("contributor.nextId"));
    }

    function getContributorId(address _fundingStorage, address _contributorAddress) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("contribution.contributorMap", _contributorAddress)));
    }

    function getContributorAddress(address _fundingStorage, uint _contributorId) internal view returns (address) {
        return FundingStorage(_fundingStorage).getAddress(keccak256(abi.encodePacked("contributor.address", _contributorId)));
    }

    function getContributesToProject(address _fundingStorage, uint _contributorId, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("contributor.contributesToProject", _contributorId, _projectId)));
    }

    function getContributorFundedProjectsLength(address _fundingStorage, uint _contributorId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("contributor.fundedProjects.length", _contributorId)));
    }

    function getContributorFundedProject(address _fundingStorage, uint _contributorId, uint _index) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("contributor.fundedProjects", _index, _contributorId)));
    }

    function getContributorFundedProjects(address _fundingStorage, uint _contributorId) internal view returns (uint[]) {
        uint length = getContributorFundedProjectsLength(_fundingStorage, _contributorId);

        uint[] memory fundedIds = new uint[](length);

        for (uint i = 0; i < length; i++) {
            fundedIds[i] = getContributorFundedProject(_fundingStorage, _contributorId, i);
        }

        return fundedIds;
    }

    function getContributor(address _fundingStorage, uint _contributorId) internal view returns (Contributor) {
        require(getContributorAddress(_fundingStorage, _contributorId) != address(0), "Contributor does not exist."); // check that contributor exists

        Contributor memory contributor = Contributor({
            id: _contributorId,
            addr: getContributorAddress(_fundingStorage, _contributorId),
            fundedProjects: getContributorFundedProjects(_fundingStorage, _contributorId)
        });

        return contributor;
    }

    function getContributionAmount(address _fundingStorage, uint _projectId, uint _contributorId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("contribution.contributionAmount", _projectId, _contributorId)));
    }

    function getProjectContributorListLength(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("contribution.contributorList.length", _projectId)));
    }

    function getProjectContributor(address _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("contribution.contributorList", _projectId, _index)));
    }



    // Setters

    function incrementNextContributorId(address _fundingStorage) internal {
        uint currentId = FundingStorage(_fundingStorage).getUint(keccak256("contributor.nextId"));
        FundingStorage(_fundingStorage).setUint(keccak256("contributor.nextId"), currentId + 1);
    }

    function setContributorId(address _fundingStorage, address _contributorAddress, uint _contributorId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("contribution.contributorMap", _contributorAddress)), _contributorId);
    }

    function setContributorAddress(address _fundingStorage, uint _contributorId, address _contributorAddress) internal {
        FundingStorage(_fundingStorage).setAddress(keccak256(abi.encodePacked("contributor.address", _contributorId)), _contributorAddress);
    }

    function setContributesToProject(address _fundingStorage, uint _contributorId, uint _projectId, bool _contributesToProject) internal {
        FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("contributor.contributesToProject", _contributorId, _projectId)), _contributesToProject);
    }

    function setContributorFundedProjectsLength(address _fundingStorage, uint _contributorId, uint _length) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("contributor.fundedProjects.length", _contributorId)), _length);
    }

    function setContributorFundedProject(address _fundingStorage, uint _contributorId, uint _index, uint _projectId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("contributor.fundedProjects", _index, _contributorId)), _projectId);
    }

    function setContributionAmount(address _fundingStorage, uint _projectId, uint _contributorId, uint _amount) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("contribution.contributionAmount", _projectId, _contributorId)), _amount);
    }

    function setProjectContributorListLength(address _fundingStorage, uint _projectId, uint _length) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("contribution.contributorList.length", _projectId)), _length);
    }

    function setProjectContributor(address _fundingStorage, uint _projectId, uint _index, uint _contributorId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("contribution.contributorList", _projectId, _index)), _contributorId);
    }
}
