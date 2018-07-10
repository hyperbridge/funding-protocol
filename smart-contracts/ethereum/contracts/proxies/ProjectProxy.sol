pragma solidity ^0.4.24;

import './OwnedUpgradeableProxy.sol';
import "../ProjectEternalStorage.sol";

contract ProjectProxy is ProjectEternalStorage, OwnedUpgradeableProxy {}
