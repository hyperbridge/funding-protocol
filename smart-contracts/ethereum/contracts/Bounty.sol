pragma solidity ^0.4.23;
import "./SafeMath.sol";

/*Developer will set bounty (non-Smart Contract related bounty)
* Bounty Hunter will report bug or test suggestions 
* Developer will dispense funds if report is approved 
* Test Bounty Params: "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", 1 , "Maple", "Greatest Bug In Existence", "http://dailyhive.com"
* Test Report Params: "This is unacceptable", "https://hyperbridge.org/"
* Remix Test Project Params: "Blockhub", "This is a description of Blockhub.", "These are the various features of Blockhub.", 1, 1000000 
* Remix Test Bounty Params: "Maple", "Greatest Bug In Existence", "http://dailyhive.com"
* Test Funding Service Params: "a", "a" , "f", 1, 1000
*/
contract Bounty {

    struct BountyHunter {
        address addr;
        string report;
        string link;
    }   

    //For Tracking the bounty to the project it is associated with
    address public projectAddress;
    uint public bountyId;

    address developer;
    string public bountyName;
    string public bountyDescription;
    string public bountyLink;
    uint public bountyValue = 0;
    bool public isComplete;
    BountyHunter[] BountyHunters;

    mapping(address => string) individualBountyHunterReport;

    modifier devRestricted() {
        require(msg.sender == developer);
        _;
    }
    
    
    constructor(address _projectAddress, uint _bountyId, string _bountyName, string _bountyDescription, string _bountyLink) public {
        projectAddress =  _projectAddress;
        bountyId = _bountyId;

        bountyName = _bountyName;
        bountyDescription = _bountyDescription;
        bountyLink = _bountyLink;
        isComplete = false;
        developer = msg.sender;
    }

    function setBountyValue() public payable devRestricted{
        bountyValue = bountyValue + msg.value;
    }

    function makeReport(string _report, string _link) public {
        BountyHunter memory newBountyHunter = BountyHunter({
            addr: msg.sender,
            report: _report,
            link: _link
        });

        BountyHunters.push(newBountyHunter);
        individualBountyHunterReport[msg.sender] = _report;
    }
    
    function viewBountyReport(address _BountyHunter) public view returns (string) {
        return individualBountyHunterReport[_BountyHunter];
    }
    
    
    function releaseBounty(address _BountyHunter) public devRestricted {
        _BountyHunter.transfer(bountyValue);
        bountyValue = this.balance;
    }
    
    
}