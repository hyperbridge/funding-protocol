pragma solidity ^0.4.23;

contract Project {
    address public launchpad;
    uint public id;
    string public title;
    string public description;
    string public about;
    uint public developerId;
    mapping(address => uint) public contributions;
    mapping(address => uint) public contributorMap; // mapping (address of contributor => index in contributors)
    address[] public contributors;

    constructor(address _launchpad, uint _id, string _title, string _description, string _about, uint _developerId) public {
        launchpad = _launchpad;
        id = _id;
        title = _title;
        description = _description;
        about = _about;
        developerId = _developerId;

        // reserve 0
        contributors.push(0);
    }

    function contribute(address _contributor) public payable {
        contributions[_contributor] += msg.value;

        if (contributorMap[_contributor] == 0) {
            contributorMap[_contributor] = contributors.length;
            contributors.push(_contributor);
        }
    }

    function getContributors() public view returns (address[]) {
        return contributors;
    }
}
