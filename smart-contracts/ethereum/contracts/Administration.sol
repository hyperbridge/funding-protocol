pragma solidity ^0.4.24;

import "./openzeppelin/Ownable.sol";
import "./libraries/storage/ProjectStorageAccess.sol";

contract Administration is Ownable {

    using ProjectStorageAccess for address;

    address fundingStorage;

    constructor(address _fundingStorage) public {
        fundingStorage = _fundingStorage;
    }

    function setProjectStatus(uint _projectId, uint _status) external onlyOwner {
        fundingStorage.setProjectStatus(_projectId, _status);
    }
}
