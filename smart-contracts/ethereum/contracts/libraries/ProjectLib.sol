pragma solidity ^0.4.24;

import "./ProjectEternalStorage.sol";
import "./ProjectStorageAccess.sol";

library ProjectLib {

    using ProjectStorageAccess for ProjectEternalStorage.ProjectStorage;

    function createProject(
        ProjectEternalStorage.ProjectStorage storage _pStorage,
        string _title,
        string _description,
        string _about,
        uint _contributionGoal,
        uint _status,
        address _developer,
        uint _developerId
    )
    external
    returns (uint)
    {
        // Get next ID from storage
        uint id = _pStorage.getNextId();
        // Increment next ID
        _pStorage.incrementNextId();

        // Create project
        _pStorage.setTitle(id, _title);
        _pStorage.setDescription(id, _description);
        _pStorage.setAbout(id, _about);
        _pStorage.setContributionGoal(id, _contributionGoal);
        _pStorage.setStatus(id, _status);
        _pStorage.setDeveloper(id, _developer);
        _pStorage.setDeveloperId(id, _developerId);

        return id;
    }
}
