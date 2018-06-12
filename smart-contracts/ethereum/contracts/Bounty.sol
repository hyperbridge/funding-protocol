pragma solidity ^0.4.23;
//import "./FundingService.sol";
//import "./Project.sol";
import "./SafeMath.sol";

/*Developer will set bounty (non-Smart Contract related bounty)
* Bounty Hunter will report bug or test suggestions 
* Developer will dispense funds if report is approved 
* Test Bounty Params: "Maple", "Greatest Bug In Existence", "http://dailyhive.com"
* Test Report Params: "This is unacceptable", "https://hyperbridge.org/"
* Test Project Params: "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", 1 , "Blockhub", "This is a description of Blockhub.", "These are the various features of Blockhub.", "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", 1000000 
* Test FUnding Service Params: "a", "a" , "f", 1, 1000
*/
contract Bounty {

    struct bountyHunter {
        address id;
        string report;
        string link;
    }   

    address developer;
    string public bountyName;
    string public bountyDescription;
    string public bountyLink;
    uint public bountyValue;
    bool public isComplete;
    bountyHunter[] bountyHunters;

    mapping(address => string) individualBountyHunterReport;

    modifier devRestricted() {
        require(msg.sender == developer);
        _;
    }
    
    
    constructor(string _bountyName, string _bountyDescription, string _bountyLink) public {
        bountyName = _bountyName;
        bountyDescription = _bountyDescription;
        bountyLink = _bountyLink;
        isComplete = false;
        developer = msg.sender;
    }

    function setBountyValue() public payable devRestricted{
        bountyValue = msg.value;
    }

    function makeReport(string _report, string _link) public {
        bountyHunter memory newBountyHunter = bountyHunter({
            id: msg.sender,
            report: _report,
            link: _link
        });

        bountyHunters.push(newBountyHunter);
        individualBountyHunterReport[msg.sender] = _report;
    }
    
    function viewBountyReport(address _bountyHunter) public view returns (string) {
        return individualBountyHunterReport[_bountyHunter];
    }
    
    
    function releaseBounty(address _bountyHunter) public devRestricted {
        _bountyHunter.transfer(bountyValue);
    }
    
    
}