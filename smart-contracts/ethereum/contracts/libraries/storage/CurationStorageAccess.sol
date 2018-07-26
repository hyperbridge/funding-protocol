pragma solidity ^0.4.24;

import "../../FundingStorage.sol";

library CurationStorageAccess {

    struct DraftCuration {
        uint timestamp;
        uint approvalCount;
        bool isActive;
    }

    /*
        In FundingStorage...
            there is a registry of curators:
                mapping(address => uint (id)) curatorMap                (curation.contributorMap)

            there is a curation threshold set:
                uint curationThreshold                                  (curation.curationThreshold)

            there are DraftCuration's (indexed by project ID):
                DraftCuration draftCuration
                    uint timestamp                                      (curation.draftCuration.timestamp)
                    uint approvalCount                                  (curation.draftCuration.approvalCount)
                    bool isActive                                       (curation.draftCuration.isActive)
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

    function getCurationThreshold(address _fundingStorage) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256("curation.curationThreshold"));
    }

    function getDraftCurationTimestamp(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("curation.draftCuration.timestamp", _projectId)));
    }

    function getDraftCurationApprovalCount(address _fundingStorage, uint _projectId) internal view returns (uint) {
        return FundingStorage(_fundingStorage).getUint(keccak256(abi.encodePacked("curation.draftCuration.approvalCount", _projectId)));
    }

    function getDraftCurationIsActive(address _fundingStorage, uint _projectId) internal view returns (bool) {
        return FundingStorage(_fundingStorage).getBool(keccak256(abi.encodePacked("curation.draftCuration.isActive", _projectId)));
    }

    function getDraftCuration(address _fundingStorage, uint _projectId) internal view returns (DraftCuration) {
        uint timestamp = getDraftCurationTimestamp(_fundingStorage, _projectId);
        uint approvalCount = getDraftCurationApprovalCount(_fundingStorage, _projectId);
        bool isActive = getDraftCurationIsActive(_fundingStorage, _projectId);

        DraftCuration memory draftCuration = DraftCuration({
            timestamp: timestamp,
            approvalCount: approvalCount,
            isActive: isActive
        });

        return draftCuration;
    }



    // Setters

    function incrementNextCuratorId(address _fundingStorage) internal {
        uint currentId = FundingStorage(_fundingStorage).getUint(keccak256("curation.nextCuratorId"));
        FundingStorage(_fundingStorage).setUint(keccak256("curation.nextCuratorId"), currentId + 1);
    }

    function setCuratorId(address _fundingStorage, address _curatorAddress, uint _curatorId) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("curation.curatorMap", _curatorAddress)), _curatorId);
    }

    function setCurationThreshold(address _fundingStorage, uint _threshold) internal {
        FundingStorage(_fundingStorage).setUint(keccak256("curation.curationThreshold"), _threshold);
    }

    function setDraftCurationTimestamp(address _fundingStorage, uint _projectId, uint _timestamp) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("curation.draftCuration.timestamp", _projectId)), _timestamp);
    }

    function setDraftCurationApprovalCount(address _fundingStorage, uint _projectId, uint _approvalCount) internal {
        FundingStorage(_fundingStorage).setUint(keccak256(abi.encodePacked("curation.draftCuration.approvalCount", _projectId)), _approvalCount);
    }

    function setDraftCurationIsActive(address _fundingStorage, uint _projectId, bool _isActive) internal {
        FundingStorage(_fundingStorage).setBool(keccak256(abi.encodePacked("curation.draftCuration.isActive", _projectId)), _isActive);
    }

    function setDraftCuration(address _fundingStorage, uint _projectId, uint _timestamp, uint _approvalCount, bool _isActive) internal {
        setDraftCurationTimestamp(_fundingStorage, _projectId, _timestamp);
        setDraftCurationApprovalCount(_fundingStorage, _projectId, _approvalCount);
        setDraftCurationIsActive(_fundingStorage, _projectId, _isActive);
    }
}
