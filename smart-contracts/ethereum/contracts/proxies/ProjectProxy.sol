pragma solidity ^0.4.24;

import './ProjectEternalStorage.sol';
import './OwnedUpgradeableProxy.sol';

contract ProjectProxy is ProjectEternalStorage, OwnedUpgradeableProxy {}
