pragma solidity ^0.4.23;

contract FundingVault {

  modifier ownerOnly() {
    require (msg.sender == owner);
    _;
  }

  modifier fundingServiceOnly() {
    require (msg.sender == fundingService);
    _;
  }

  modifier activeOnly() {
    require(active == true);
  }

  address fundingService;

  address owner;

  bool active;

  function FundingVault(address _fundingService) {
    owner = msg.sender;
    setFundingServiceContract(_fundingService);
  }

  function setFundingServiceContract(address _fundingService) ownerOnly {
    fundingService = _fundingService;
  }

  function setActive(bool val) ownerOnly {
    active = val;
  }

  function deposite() payable {

  }


  function withdraw(uint _amount, address _receiver) fundingServiceOnly activeOnly {
    require(this.balance >= _amount);
    _receiver.transfer(_amount);
  }

}
