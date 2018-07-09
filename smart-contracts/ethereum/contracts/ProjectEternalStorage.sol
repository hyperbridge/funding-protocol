pragma solidity ^0.4.24;

contract ProjectEternalStorage {

    struct ProjectStorage {
        mapping(bytes32 => uint256)    uIntStorage;
        mapping(bytes32 => string)     stringStorage;
        mapping(bytes32 => address)    addressStorage;
        mapping(bytes32 => bytes)      bytesStorage;
        mapping(bytes32 => bool)       boolStorage;
        mapping(bytes32 => int256)     intStorage;
    }

    ProjectStorage internal pStorage;
}
