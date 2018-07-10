pragma solidity ^0.4.24;

contract ProxyStorage {

    address internal implementation;

    function getImplementation() public view returns (address) {
        return implementation;
    }
}