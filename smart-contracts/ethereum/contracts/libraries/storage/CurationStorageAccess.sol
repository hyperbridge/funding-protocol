pragma solidity ^0.4.24;

import "../../FundingStorage.sol";

library CurationStorageAccess {

    /*
        In FundingStorage...
            there is a registry of curators:
                mapping(address => uint (id)) curatorMap                (curation.contributorMap)

            there is a curation threshold set:
                uint curationThreshold                                  (curation.curationThreshold)

    */

    // Getters

    function generateNewCuratorId(address _fundingStorage) internal returns (uint) {
        uint id = getNextCuratorId(_fundingStorage);
        incrementNextCuratorId(_fundingStorage);
        return id;
    }

    function getNextCuratorId(address _fundingStorage) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256("curation.nextCuratorId"));
    }

    function getCuratorId(address _fundingStorage, address _curatorAddress) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("curation.curatorMap", _curatorAddress)));
    }



    // Setters

    function incrementNextCuratorId(address _fundingStorage) internal {
        uint currentId = FundingStorage(_fundingStorage).getUint(keccak256("curation.nextCuratorId"));
        FundingStorage(_fundingStorage).setUint(keccak256("curation.nextCuratorId"), currentId + 1);
    }

    function setCuratorId(address _fundingStorage, address _curatorAddress, uint _curatorId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("curation.curatorMap", _curatorAddress)), _curatorId);
    }
}
