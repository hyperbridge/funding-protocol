pragma solidity ^0.4.24;

import './UpgradeableProxy.sol';
import './openzeppelin/Ownable.sol';

contract OwnedUpgradeableProxy is Ownable, UpgradeableProxy {

    function upgradeTo(string version, address implementation) public onlyOwner {
        _upgradeTo(version, implementation);
    }

    function upgradeToAndCall(string version, address implementation, bytes data) payable public onlyOwner {
        upgradeTo(version, implementation);
        require(this.call.value(msg.value)(data));
    }
}