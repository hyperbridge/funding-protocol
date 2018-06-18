pragma solidity ^0.4.24;

import "./ERC20.sol";
import "./ERC20Basic.sol";
import "./Pausable.sol";

contract FundingVault is Pausable {

    modifier fundingServiceOnly() {
        require (msg.sender == fundingService);
        _;
    }
    address fundingService;


    constructor(address _fundingService) public {
        setFundingServiceContract(_fundingService);
    }

    function () public payable {
        revert();
    }

    function setFundingServiceContract(address _fundingService) public onlyOwner {
        fundingService = _fundingService;
    }

    event EthDeposited(uint amount);

    function depositEth() public payable fundingServiceOnly whenNotPaused {

        emit EthDeposited(msg.value);
    }

    event EthWithdrawn(address receiver, uint amount);

    function withdrawEth(uint _amount, address _receiver) public fundingServiceOnly whenNotPaused {
        require(_receiver != address(0));
        require(_amount > 0);
        require(getBalance() >= _amount);

        emit EthWithdrawn(_receiver, _amount);

        _receiver.transfer(_amount);
    }

    event TokenWithdrawn(address tokenAddress, address receiver, uint amount);

    function withdrawToken(address _tokenAddress, uint _amount, address _receiver) public fundingServiceOnly whenNotPaused {
        require(_receiver != address(0));
        require(_amount > 0);
        ERC20 token = ERC20(_tokenAddress);
        require (token.balanceOf(this) >= _amount);

        emit TokenWithdrawn(_tokenAddress, _receiver, _amount);

        require(token.transfer(_receiver, _amount));
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

}
