pragma solidity ^0.4.23;
//import "./FundingService.sol";
//import "./Project.sol";
import "./SafeMath.sol";

/*Developer will set bounty (non-Smart Contract related bounty)
* Bounty Hunter will report bug or test suggestions 
* Developer will dispense funds if report is approved 
* Test Bounty Params: "Maple", "Greatest Bug In Existence", "http://dailyhive.com"
* Test Report Params: "This is unacceptable", "https://hyperbridge.org/"
*/
contract Bounty {

    struct bountyHunter {
        address id;
        string report;
        string link;
    }   

    address developer;
    string bountyName;
    string bountyDescription;
    string bountyLink;
    uint bountyValue;
    bool isComplete;
    bountyHunter[] bountyHunters;

    mapping(address => string) allBountyHunterReports;
    
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
        allBountyHunterReports[msg.sender] = _report;
    }
    
    function viewBountyReport(address _bountyHunter) public view devRestricted returns (string) {
        return allBountyHunterReports[_bountyHunter];
    }
    
    function releaseBounty(address _bountyHunter) public devRestricted {
        _bountyHunter.transfer(bountyValue);
    }
    
    
}