pragma solidity ^0.4.24;

contract ProjectStorage {

    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;

    // Getters

    function getAddress(bytes32 _key) internal view returns (address) {
        return addressStorage[_key];
    }

    function getUint(bytes32 _key) internal view returns (uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) internal view returns (string) {
        return stringStorage[_key];
    }

    function getBytes(bytes32 _key) internal view returns (bytes) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) internal view returns (bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) internal view returns (int) {
        return intStorage[_key];
    }

    // Setters

    function setAddress(bytes32 _key, address _value) internal {
        addressStorage[_key] = _value;
    }

    function setUint(bytes32 _key, uint _value) internal {
        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value) internal {
        stringStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value) internal {
        bytesStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) internal {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value) internal {
        intStorage[_key] = _value;
    }

    // Delete

    function deleteAddress(bytes32 _key) internal {
        delete addressStorage[_key];
    }

    function deleteUint(bytes32 _key) internal {
        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) internal {
        delete stringStorage[_key];
    }

    function deleteBytes(bytes32 _key) internal {
        delete bytesStorage[_key];
    }

    function deleteBool(bytes32 _key) internal {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key) internal {
        delete intStorage[_key];
    }
}
