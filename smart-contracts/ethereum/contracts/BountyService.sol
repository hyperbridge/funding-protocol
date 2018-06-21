pragma solidity ^0.4.23;

import "./strings.sol";
import "./SafeMath.sol";

/*
* Test createBounty Params: 1, "0xef55bfac4228981e850936aaf042951f7b146e41", "xiaxia", "Test bug description for Maple", "http://dailyhive.com"
* Test submitReport Params: 0, "Test Submit Report: Look at 000"
*/
contract BountyService {

    struct Bounty {
        uint bountyId;
        address targetId;           //Target of Id of the bounty (eg. Project)
        address developerAddress;
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
        mapping(uint => uint) BountyIdIndex;    // mapping of bounty id to index in Developer.bountyIds
        uint[] bountyIds;                       // the bounties belonging to this developer
    }
    

    address public owner;
    mapping(address => uint) public developerMap;       // address => id
    Developer[] public developers;                      // indexed by developer id
    uint public bountyIdCounter;                        // Helps to give each bounty a unique uint ID
    Bounty[] public bountyCollection;                          // Indexed by BountyId

    mapping(address => uint[]) public targetBountyMap;      //Pass the target ID and returns the bountyId's associated with it
    mapping(uint => string[]) public bountyReportMap;       //Map all the bounty reports to its bounty
    mapping(uint => address[]) public bountyHunterReportMap; //Map to keep track of bounty Hunters that submit reports. To be used in conjunction with bountyReportMap

    modifier devRestricted(uint _developerId) {
        require(developers[_developerId].id == _developerId); // check that developer exists
        require(msg.sender == developers[_developerId].addr);
        _;
    }
    
    modifier bountyStillLive(uint _bountyId) {
        require(bountyCollection[_bountyId].isComplete == false);
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
    
    function createBounty(uint _developerId, address _targetId, string _bountyName, string _bountyDescription, string _bountyLink) payable public devRestricted(_developerId){
        
        
        Bounty memory newBounty = Bounty({
            bountyId: bountyIdCounter,
            targetId: _targetId,
            developerAddress: msg.sender,
            bountyName: _bountyName,
            bountyDescription: _bountyDescription,
            bountyLink: _bountyLink,
            bountyValue: msg.value,
            isComplete: false,
            approvedHunterMap: new address[](0)
        });
        
        targetBountyMap[newBounty.targetId].push(newBounty.bountyId);
        developers[_developerId].bountyIds.push(newBounty.bountyId);
        bountyCollection.push(newBounty);
        bountyIdCounter++;
        
    }
    
    function submitBountyReport(uint _bountyId, string _report) public bountyStillLive(_bountyId){
        bountyReportMap[_bountyId].push(_report);
        bountyHunterReportMap[_bountyId].push(msg.sender);
        bountyCollection[_bountyId].compensatedHunterMap[msg.sender] = false;

    }
    
    function getReportsforBounty(uint _bountyId) public view returns (string) {
        string memory bountyConcatString;
        for (uint i=0; i < bountyReportMap[_bountyId].length; i++) {
            
            bountyConcatString = strings.concat(strings.toSlice(bountyConcatString), strings.toSlice("#REPORT#"));
            bountyConcatString = strings.concat(strings.toSlice(bountyConcatString), strings.toSlice(bountyReportMap[_bountyId][i]));
        }
        return bountyConcatString;
    }
    
    
    //Move a BountyHunter to the approved Bounty Hunter array
    //Perform before releasing bounty
    function approveBountyHunter(uint _bountyId, address _bountyHunter) public{
        require(bountyCollection[_bountyId].developerAddress == msg.sender);    //Check if it is the original developer that created this bounty

        bountyCollection[_bountyId].approvedHunterMap.push(_bountyHunter);
    }
    
    
    function getApprovedBountyHunters(uint _bountyId) public view returns (address[]) {
        return bountyCollection[_bountyId].approvedHunterMap;
    }
    
    
    // Release Bounty to bounty hunters on the approvedHunterMap array of a Bounty
    function releaseBounty(uint _bountyId, uint _developerId) public devRestricted(_developerId) {
        require(bountyCollection[_bountyId].developerAddress == msg.sender);    //Check if it is the original developer that created this bounty
        
        uint bountyShare = SafeMath.div(bountyCollection[_bountyId].bountyValue, bountyCollection[_bountyId].approvedHunterMap.length);
        
        for (uint i=0; i< bountyCollection[_bountyId].approvedHunterMap.length; i++) {
            bountyCollection[_bountyId].approvedHunterMap[i].transfer(bountyShare);
        }
    }
    
    function closeBounty(uint _bountyId, uint _developerId) public devRestricted(_developerId) bountyStillLive(_bountyId) {
        require(bountyCollection[_bountyId].developerAddress == msg.sender);
        
        bountyCollection[_bountyId].isComplete = true;
    }
    
    
    function getBountyStatus(uint _bountyId) public view returns (bool) {
        return bountyCollection[_bountyId].isComplete;
    }
    
    function getBountyValue(uint _bountyId) public view returns (uint) {
        return bountyCollection[_bountyId].bountyValue;
    }
    



    function() public payable { }
}



