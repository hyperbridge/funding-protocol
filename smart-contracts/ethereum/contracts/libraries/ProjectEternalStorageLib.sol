pragma solidity ^0.4.24;

import "../ProjectEternalStorage.sol";

library ProjectEternalStorageLib {

    // Getters

    function getAddress(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external view returns (address) {
        return _pStorage.addressStorage[_key];
    }

    function getUint(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external view returns (uint) {
        return _pStorage.uIntStorage[_key];
    }

    function getString(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external view returns (string) {
        return _pStorage.stringStorage[_key];
    }

    function getBytes(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external view returns (bytes) {
        return _pStorage.bytesStorage[_key];
    }

    function getBool(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external view returns (bool) {
        return _pStorage.boolStorage[_key];
    }

    function getInt(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external view returns (int) {
        return _pStorage.intStorage[_key];
    }

    // Setters

    function setAddress(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key, address _value) external {
        _pStorage.addressStorage[_key] = _value;
    }

    function setUint(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key, uint _value) external {
        _pStorage.uIntStorage[_key] = _value;
    }

    function setString(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key, string _value) external {
        _pStorage.stringStorage[_key] = _value;
    }

    function setBytes(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key, bytes _value) external {
        _pStorage.bytesStorage[_key] = _value;
    }

    function setBool(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key, bool _value) external {
        _pStorage.boolStorage[_key] = _value;
    }

    function setInt(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key, int _value) external {
        _pStorage.intStorage[_key] = _value;
    }

    // Delete

    function deleteAddress(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external {
        delete _pStorage.addressStorage[_key];
    }

    function deleteUint(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external {
        delete _pStorage.uIntStorage[_key];
    }

    function deleteString(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external {
        delete _pStorage.stringStorage[_key];
    }

    function deleteBytes(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external {
        delete _pStorage.bytesStorage[_key];
    }

    function deleteBool(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external {
        delete _pStorage.boolStorage[_key];
    }

    function deleteInt(ProjectEternalStorage.ProjectStorage storage _pStorage, bytes32 _key) external {
        delete _pStorage.intStorage[_key];
    }
}
