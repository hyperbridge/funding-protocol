pragma solidity ^0.4.24;


// TODO move ERC20 interface to a separate file

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



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
    _;
  }

  address fundingService;

  address owner;

  //TODO import pausable?
  bool active;

  constructor(address _owner, address _fundingService) public {
    owner = _owner;
    setFundingServiceContract(_fundingService);
    setActive(true);
  }

  function setFundingServiceContract(address _fundingService) public ownerOnly {
    fundingService = _fundingService;
  }

  function setActive(bool val) public ownerOnly {
    active = val;
  }

  event ETHDeposited(uint amount);

  function depositeETH() public payable  fundingServiceOnly activeOnly {

    emit ETHDeposited(msg.value);
  }

  event ETHWithdrawn(address receiver, uint amount);

  function withdrawETH(uint _amount, address _receiver) public  fundingServiceOnly activeOnly {
    require(_receiver != address(0));
    require(_amount > 0);
    require(getBalance() >= _amount);

    emit ETHWithdrawn(_receiver, _amount);

    _receiver.transfer(_amount);
  }

  event ERC20Withdrawn(address ERC20, address receiver, uint amount);

  function withdrawERC20(address _ERC20Adress, uint _amount, address _receiver) public fundingServiceOnly activeOnly {
      require(_amount > 0);
      ERC20 token = ERC20(_ERC20Adress);
      require (token.balanceOf(this) > _amount);

      emit ERC20Withdrawn(_ERC20Adress, _receiver, _amount);

      require(token.transfer(_receiver,_amount));
  }

  function getBalance() public view returns(uint) {
    return address(this).balance;
  }

}
