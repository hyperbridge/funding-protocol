pragma solidity ^0.4.23;

/*
* Test createBounty Params: 1, "0xef55bfac4228981e850936aaf042951f7b146e41", "xiaxia", "Test bug description for Maple", "http://dailyhive.com"

*/
contract BountyService {

    struct Bounty {
        uint bountyId;
        bytes32 targetId;           //Target of Id of the bounty (eg. Project)
        string bountyName;
        string bountyDescription;
        string bountyLink;          //Attach link that further describes the bounty
        uint bountyValue;
        bool isComplete;
        address[] approvedHunterMap;                    //Hunters that are selected to be compensated
        mapping(address => bool) compensatedHunterMap;  //Hunters who will have been compensated will be mapped as true
        
    }

    struct Developer {
        uint id;
        address addr;
        string name;
        mapping(uint => uint) BountyIdIndex; // mapping of bounty id to index in Developer.bountyIds
        uint[] bountyIds; // the bounties belonging to this developer
    }

    address public owner;
    mapping(address => uint) public developerMap;       // address => id
    Developer[] public developers;                      // indexed by developer id
    uint private bountyIdCounter;                       // Helps to give each bounty a unique uint ID
    Bounty[] bountyCollection;                          // Indexed by BountyId

    mapping(bytes32 => uint[]) public targetBountyMap;      //Pass the target ID and returns the bountyId's associated with it
    mapping(uint => string[]) public bountyReportMap;       //Map all the bounty reports to its bounty
    mapping(uint => address[]) public bountyHunterReportMap; //Map to keep track of bounty Hunters that submit reports. To be used in conjunction with bountyReportMap

    modifier devRestricted(uint _developerId) {
        require(developers[_developerId].id == _developerId); // check that developer exists
        require(msg.sender == developers[_developerId].addr);
        _;
    }

    constructor() public {
        owner = msg.sender;

        // reserve 0
        developers.length++;
        //bounties.push(0);
    }

    function createDeveloper(string _name) public {
        require(developerMap[msg.sender] == 0); // require that this account is not already a developer

        Developer memory newDeveloper = Developer({
            id: developers.length,
            addr: msg.sender,
            name: _name,
            bountyIds: new uint[](0)
            });

        developers.push(newDeveloper);
        developerMap[msg.sender] = newDeveloper.id;
    }
    
    //TODO only allow developers to create a new bounty
    function createBounty(uint _developerId, bytes32 _targetId, string _bountyName, string _bountyDescription, string _bountyLink) payable public{
        
        
        Bounty memory newBounty = Bounty({
            bountyId: bountyIdCounter,
            targetId: _targetId,
            bountyName: _bountyName,
            bountyDescription: _bountyDescription,
            bountyLink: _bountyLink,
            bountyValue: msg.value,
            isComplete: false
        });
        
        targetBountyMap[newBounty.targetId].push(newBounty.bountyId);
        developers[_developerId].bountyIds.push(newBounty.bountyId);
        bountyCollection.push(newBounty);
        bountyIdCounter++;
        
    }
    
    function submitBountyReport(uint _bountyId, string _report) public {
        bountyReportMap[_bountyId].push(_report);
        bountyHunterReportMap[_bountyId].push(msg.sender);
        bountyCollection[_bountyId].compensatedHunterMap[msg.sender] = false;

    }
    
    // function getReportsforBounty(uint _bountyId) public view returns (string) {
    //     string memory bountyConcatString;
    //     for (uint i=0; i > bountyReportMap[_bountyId].length; i++) {
            
    //         bountyConcatString = bountyReportMap[_bountyId][i] + bountyReportMap[_bountyId][i+1];
    //     }
    // }




    function() public payable { }
}