pragma solidity ^0.4.24;

import './UpgradeableProxy.sol';
import "../openzeppelin/Ownable.sol";

contract OwnedUpgradeableProxy is Ownable, UpgradeableProxy {

    function upgradeTo(address implementation) public onlyOwner {
        _upgradeTo(implementation);
    }

    function upgradeToAndCall(address implementation, bytes data) payable public onlyOwner {
        upgradeTo(implementation);
        require(address(this).call.value(msg.value)(data));
    }
}