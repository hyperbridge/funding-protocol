pragma solidity ^0.4.24;

import './Proxy.sol';
import './ProxyStorage.sol';

contract UpgradeableProxy is Proxy, ProxyStorage {

    event Upgraded(address indexed implementation);

    function _upgradeTo(address _implementation) internal {
        require(_implementation != implementation);
        implementation = _implementation;
        Upgraded(_implementation);
    }
}