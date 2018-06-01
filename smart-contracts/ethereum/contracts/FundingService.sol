pragma solidity ^0.4.23;
import "./Project.sol";
import "./SafeMath.sol";

contract FundingService {

    using SafeMath for uint256;

    struct Developer {
        uint id;
        address addr;
        string name;
        mapping(uint => uint) projectIdIndex; // mapping of project id to index in Developer.projectIds
        uint[] projectIds; // the projects belonging to this developer
    }

    struct Contributor {
        address addr;
        mapping(address => bool) projectExists;
        address[] activeProjects;
    }

    address public owner;

    mapping(address => uint) public developerMap; // address => id
    Developer[] public developers; // indexed by developer id

    mapping(address => Contributor) public contributors;

    mapping(address => mapping(address => uint)) public projectContributionAmount; // project address => (contributor address => contribution amount)
    mapping(address => address[]) public projectContributorList; // project address => Contributors[]

    mapping(address => uint) public projectMap; // address => id
    address[] public projects; // indexed by project id

    modifier devRestricted(uint _developerId) {
        require(developers[_developerId].id == _developerId); // check that developer exists
        require(msg.sender == developers[_developerId].addr);
        _;
    }

    constructor() public {
        owner = msg.sender;

        // reserve 0
        developers.length++;
        projects.push(0);
    }

    function createDeveloper(string _name) public {
        require(developerMap[msg.sender] == 0); // require that this account is not already a developer

        Developer memory newDeveloper = Developer({
            id: developers.length,
            addr: msg.sender,
            name: _name,
            projectIds: new uint[](0)
            });

        developers.push(newDeveloper);
        developerMap[msg.sender] = newDeveloper.id;
    }

    function getDeveloper(uint _id) public view returns (address addr, string name, uint[] projectIds) {
        require(developers[_id].id == _id); // check that developer exists

        Developer memory dev = developers[_id];
        return (dev.addr, dev.name, dev.projectIds);
    }

    function getDevelopers() public view returns (address[]) {
        address[] memory addresses = new address[](developers.length - 1);

        for (uint i = 1; i < developers.length; i++) {
            Developer memory developer = developers[i];
            addresses[i - 1] = (developer.addr);
        }

        return addresses;
    }

    function createProject(string _title, string _description, string _about, uint _developerId, uint _contributionGoal) public devRestricted(_developerId) {
        uint newProjectId = projects.length;

        Project newProject = new Project(this, newProjectId, _title, _description, _about,  msg.sender,  _developerId, _contributionGoal);

        projectMap[newProject] = newProjectId;
        projects.push(newProject);

        Developer storage dev = developers[_developerId];

        dev.projectIds.push(newProjectId);
    }

    function submitProjectForReview(uint _projectId, uint _developerId) public devRestricted(_developerId) {
        address projectAddress = projects[_projectId];

        // check that project exists
        require(projectAddress != address(0));

        Project project = Project(projectAddress);

        verifyProjectMilestones(project);

        verifyProjectTiers(project);

        // Set project status to "Pending"
        project.setStatus(1);
    }

    function verifyProjectMilestones(Project _project) private view {
        // Get project terms
        // 0: NoRefunds
        // 1: NoTimeline
        Project.Terms[] memory terms = _project.getTerms();

        // Determine if project has a NoTimeline terms
        bool hasNoTimeline = false;
        for (uint i = 0; i < terms.length; i++) {
            if (terms[i] == Project.Terms.NoTimeline) {
                hasNoTimeline = true;
                break;
            }
        }

        // If project has a timeline, verify:
        // - Milestones are present
        // - Milestone percentages add up to 100
        if (!hasNoTimeline) {
            uint timelineLength = _project.getTimelineMilestoneLength();

            require(timelineLength > 0);

            uint percentageAcc = 0;
            for (uint j = 0; j < timelineLength; j++) {
                // todo - is there a way to ignore multiple returns?
                string memory title;
                string memory description;
                uint percentage;
                bool isComplete;
                (title, description, percentage, isComplete) = _project.getTimelineMilestone(j);
                percentageAcc = percentageAcc.add(percentage);
            }
            require(percentageAcc == 100);
        }
    }

    function verifyProjectTiers(Project _project) private view {
        // Verify that project has contribution tiers
        uint tiersLength = _project.getTiersLength();
        require(tiersLength > 0);
    }

    function getProjects() public view returns (address[]) {
        address[] memory addresses = new address[](projects.length - 1);

        for (uint i = 1; i < projects.length; i++) {
            addresses[i - 1] = projects[i];
        }

        return addresses;
    }

    function contributeToProject(uint _projectId) public payable {
        address projectAddress = projects[_projectId];

        require(projectAddress != 0); // check that project exists

        // if contributor doesn't exist, create it
        if (contributors[msg.sender].addr == 0) {
            Contributor memory newContributor = Contributor({
                addr: msg.sender,
                activeProjects: new address[](0)
                });

            // add contributor to global contributors mapping
            contributors[msg.sender] = newContributor;
        }

        Contributor storage contributor = contributors[msg.sender];

        // if project is not in contributor's project list, add it
        if (!contributor.projectExists[projectAddress]) {
            contributor.projectExists[projectAddress] = true;
            contributor.activeProjects.push(projectAddress);
        }

        // add to projectContributorList, if not already present
        if (projectContributionAmount[projectAddress][msg.sender] == 0) {
            projectContributorList[projectAddress].push(msg.sender);
        }

        // add contribution amount to project
        uint currentProjectContributionAmount = projectContributionAmount[projectAddress][msg.sender];
        projectContributionAmount[projectAddress][msg.sender] = currentProjectContributionAmount.add(msg.value);

        // transfer money to project
        projectAddress.transfer(msg.value);
    }

    function getProjectContributorList(address _project) public view returns (address[]) {
        return projectContributorList[_project];
    }
}
