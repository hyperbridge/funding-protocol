pragma solidity ^0.4.24;

contract ProjectEternalStorage {


    /**** Storage Types *******/

    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;

    /*** Modifiers ************/

    // modifier onlyLatestProjectContract() {
    //     // The owner is only allowed to set the storage upon deployment to register the initial contracts, afterwards their direct access is disabled
    //     if (msg.sender == owner) {
    //         require(boolStorage[keccak256("contract.storage.initialised")] == false);
    //     } else {
    //         // Make sure the access is permitted to only contracts in our Dapp
    //         require(addressStorage[keccak256("contract.address", msg.sender)] != 0x0);
    //     }
    //     _;
    // }

    /**** Getters ***********/

    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    /**** Setters ***********/


    function setAddress(bytes32 _key, address _value) external {
        addressStorage[_key] = _value;
    }

    function setUint(bytes32 _key, uint _value) external {
        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value) external {
        stringStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value) external {
        bytesStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) external {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value) external {
        intStorage[_key] = _value;
    }

    /**** Deletion ***********/

    function deleteAddress(bytes32 _key) external {
        delete addressStorage[_key];
    }

    function deleteUint(bytes32 _key) external {
        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) external {
        delete stringStorage[_key];
    }

    function deleteBytes(bytes32 _key) external {
        delete bytesStorage[_key];
    }

    function deleteBool(bytes32 _key) external {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key) external {
        delete intStorage[_key];
    }
}
