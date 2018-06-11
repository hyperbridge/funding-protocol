const FundingService = artifacts.require("FundingService");
const Project = artifacts.require("Project");

contract('ProjectMilestones', function(accounts) {
    let fundingService;
    let fundingServiceOwner;
    let devName;
    let devAccount;
    let project;
    let projectTitle;
    let projectDescription;
    let projectAbout;
    let projectDevId;
    let projectContributionGoal;

    before(async () => {
        fundingService = await FundingService.deployed();

        devName = "Hyperbridge";
        fundingServiceOwner = accounts[0];
        devAccount = accounts[1];

        await fundingService.createDeveloper(devName, { from: devAccount });

        projectTitle = "Blockhub";
        projectDescription = "This is a description of Blockhub.";
        projectAbout = "These are the various features of Blockhub.";
        projectDevId = await fundingService.developerMap.call(devAccount);
        projectContributionGoal = 1000000;

        await fundingService.createProject(projectTitle, projectDescription, projectAbout, projectDevId, projectContributionGoal, {from: devAccount});

        let projectAddress = await fundingService.projects.call(1);
        project = Project.at(projectAddress);
    });

    it("should be able to add initial milestones", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 20, false, { from: devAccount });

            let timelineMilestoneLength = await project.getTimelineMilestoneLength.call();
            assert.equal(timelineMilestoneLength.toNumber(), 1, "Milestone not added.");

            await project.addMilestone(milestoneTitle, milestoneDescription, 30, false, { from: devAccount });

            timelineMilestoneLength = await project.getTimelineMilestoneLength.call();
            assert.equal(timelineMilestoneLength.toNumber(), 2, "Second milestone not added.");

            await project.addMilestone(milestoneTitle, milestoneDescription, 50, false, { from: devAccount });
            timelineMilestoneLength = await project.getTimelineMilestoneLength.call();
            assert.equal(timelineMilestoneLength.toNumber(), 3, "Third milestone not added.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should reject wrong account from adding milestones", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 20, false, { from: accounts[2] });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should reject milestone with percentage > 100", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 101, false, { from: devAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should be able to edit a timeline milestone when timeline is inactive", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 20, false, { from: devAccount });

            let milestone = await project.getMilestone.call(0, false, { from: devAccount });

            assert.equal(milestone[0], milestoneTitle, "Title is wrong.");
            assert.equal(milestone[1], milestoneDescription, "Description is wrong.");
            assert.equal(milestone[2].toNumber(), 20, "Percentage is wrong.");

            let newTitle = "New Milestone";
            let newDescription = "New description";

            await project.editMilestone(0, false, newTitle, newDescription, 30, { from: devAccount });

            milestone = await project.getMilestone.call(0, false, { from: devAccount });

            assert.equal(milestone[0], newTitle, "Title is wrong.");
            assert.equal(milestone[1], newDescription, "Description is wrong.");
            assert.equal(milestone[2].toNumber(), 30, "Percentage is wrong.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to edit a pending milestone", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(1, 1, { from: devAccount });

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, true, { from: devAccount });

            let milestone = await project.getMilestone.call(0, true, { from: devAccount });

            assert.equal(milestone[0], milestoneTitle, "Title is wrong.");
            assert.equal(milestone[1], milestoneDescription, "Description is wrong.");
            assert.equal(milestone[2].toNumber(), 100, "Percentage is wrong.");

            let newTitle = "New Milestone";
            let newDescription = "New description";

            await project.editMilestone(0, true, newTitle, newDescription, 30, { from: devAccount });

            milestone = await project.getMilestone.call(0, true, { from: devAccount });

            assert.equal(milestone[0], newTitle, "Title is wrong.");
            assert.equal(milestone[1], newDescription, "Description is wrong.");
            assert.equal(milestone[2].toNumber(), 30, "Percentage is wrong.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});

contract('ProjectTerms', function(accounts) {
    let fundingService;
    let fundingServiceOwner;
    let devName;
    let devAccount;
    let project;
    let projectTitle;
    let projectDescription;
    let projectAbout;
    let projectDevId;
    let projectContributionGoal;

    before(async () => {
        fundingService = await FundingService.deployed();

        devName = "Hyperbridge";
        fundingServiceOwner = accounts[0];
        devAccount = accounts[1];

        await fundingService.createDeveloper(devName, { from: devAccount });

        projectTitle = "Blockhub";
        projectDescription = "This is a description of Blockhub.";
        projectAbout = "These are the various features of Blockhub.";
        projectDevId = await fundingService.developerMap.call(devAccount);
        projectContributionGoal = 1000000;

        await fundingService.createProject(projectTitle, projectDescription, projectAbout, projectDevId, projectContributionGoal, {from: devAccount});

        let projectAddress = await fundingService.projects.call(1);
        project = Project.at(projectAddress);
    });

    it("should be able to set project terms", async () => {
        try {
            await project.setNoTimeline(true, { from: devAccount });
            let hasNoTimeline = await project.noTimeline.call();
            assert.equal(hasNoTimeline, true, "noTimeline not set properly.");

            await project.setNoTimeline(false, { from: devAccount });
            hasNoTimeline = await project.noTimeline.call();
            assert.equal(hasNoTimeline, false, "noTimeline not set properly.");

            await project.setNoRefunds(true, { from: devAccount });
            let hasNoRefunds = await project.noRefunds.call();
            assert.equal(hasNoRefunds, true, "noRefunds not set properly.");

            await project.setNoRefunds(false, { from: devAccount });
            hasNoRefunds = await project.noRefunds.call();
            assert.equal(hasNoRefunds, false, "noRefunds not set properly.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});

contract('ProjectTiers', function(accounts) {
    let fundingService;
    let fundingServiceOwner;
    let devName;
    let devAccount;
    let project;
    let projectId;
    let projectTitle;
    let projectDescription;
    let projectAbout;
    let projectDevId;
    let projectContributionGoal;

    before(async () => {
        fundingService = await FundingService.deployed();

        devName = "Hyperbridge";
        fundingServiceOwner = accounts[0];
        devAccount = accounts[1];

        await fundingService.createDeveloper(devName, { from: devAccount });

        projectTitle = "Blockhub";
        projectDescription = "This is a description of Blockhub.";
        projectAbout = "These are the various features of Blockhub.";
        projectDevId = await fundingService.developerMap.call(devAccount);
        projectContributionGoal = 1000000;

        await fundingService.createProject(projectTitle, projectDescription, projectAbout, projectDevId, projectContributionGoal, {from: devAccount});

        let projectAddress = await fundingService.projects.call(1);
        project = Project.at(projectAddress);
    });

    it("should be able to add tiers", async () => {
        try {
            const contributorLimit = 1000;
            let maxContribution = 10000;
            let minContribution = 1;
            let rewards = "You'll get these things.";

            await project.addTier(contributorLimit, maxContribution, minContribution, rewards, { from: devAccount });

            let pendingTiersLength = await project.getPendingTiersLength.call();
            assert.equal(pendingTiersLength.toNumber(), 1, "Pending tier was not added.");

            await project.finalizeTiers({ from: devAccount });

            let tiersLength = await project.getTiersLength.call();
            pendingTiersLength = await project.getPendingTiersLength.call();

            assert.equal(tiersLength.toNumber(), 1, "Finalizing tiers did not move pending into active.");
            assert.equal(pendingTiersLength.toNumber(), 0, "Finalizing tiers did not clear pendingTiers.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});

contract('ProjectTimelineProposalVoting', function(accounts) {
    let fundingService;
    let fundingServiceOwner;
    let devName;
    let devAccount;
    let project;
    let projectId;
    let projectTitle;
    let projectDescription;
    let projectAbout;
    let projectDevId;
    let projectContributionGoal;

    before(async () => {
        fundingService = await FundingService.deployed();

        devName = "Hyperbridge";
        fundingServiceOwner = accounts[0];
        devAccount = accounts[1];
        projectId = 0;

        await fundingService.createDeveloper(devName, { from: devAccount });
    });

    beforeEach(async () => {
        projectTitle = "Blockhub";
        projectDescription = "This is a description of Blockhub.";
        projectAbout = "These are the various features of Blockhub.";
        projectDevId = await fundingService.developerMap.call(devAccount);
        projectContributionGoal = 1000000;

        await fundingService.createProject(projectTitle, projectDescription, projectAbout, projectDevId, projectContributionGoal, {from: devAccount});

        projectId++;

        let projectAddress = await fundingService.projects.call(projectId);
        project = await Project.at(projectAddress);
    });

    it("can only suggest new timeline if current timeline is active", async () => {
        try {
            await project.proposeNewTimeline({ from: devAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("can only suggest new timeline if there is not currently a vote on milestone completion", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(1, 1, { from: devAccount });

            await project.submitMilestoneCompletion("This milestone is done.", { from: devAccount });

            await project.addMilestone("Milestone 2", "Milestone 2 description", 100, true, { from: devAccount });

            await project.proposeNewTimeline({ from: devAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("can suggest new timeline", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await project.addMilestone("Milestone 2", "Milestone 2 description", 100, true, { from: devAccount });

            await project.proposeNewTimeline({ from: devAccount });

            const timelineProposal = await project.getTimelineProposal.call();

            assert.equal(timelineProposal[3], true, "Timeline Proposal is not active.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("contributor can vote on timeline proposal", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: 100 });

            await project.addMilestone("Milestone 2", "Milestone 2 description", 100, true, { from: devAccount });

            await project.proposeNewTimeline({ from: devAccount });

            await project.voteOnTimelineProposal(true, { from: accounts[2] });

            const userHasVoted = await project.hasVotedOnTimelineProposal.call({ from: accounts[2] });

            assert.equal(userHasVoted, true, "User vote not registered.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-contributor cannot vote on timeline proposal", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: 100 });

            await project.addMilestone("Milestone 2", "Milestone 2 description", 100, true, { from: devAccount });

            await project.proposeNewTimeline({ from: devAccount });

            await project.voteOnTimelineProposal(true, { from: accounts[3] });

            assert.fail();
        } catch (e) {
            console.log(e.message);
            const userHasVoted = await project.hasVotedOnTimelineProposal.call({ from: accounts[3] });

            assert.equal(userHasVoted, false, "User vote registered incorrectly.");
        }
    });

    it("developer can finalize timeline proposal early with over 75% support", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[3], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[4], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[5], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[6], value: 100 });

            await project.addMilestone("Milestone 2", "Milestone 2 description", 100, true, { from: devAccount });

            await project.proposeNewTimeline({ from: devAccount });

            await project.voteOnTimelineProposal(true, { from: accounts[2] });
            await project.voteOnTimelineProposal(true, { from: accounts[3] });
            await project.voteOnTimelineProposal(true, { from: accounts[4] });
            await project.voteOnTimelineProposal(true, { from: accounts[5] });
            await project.voteOnTimelineProposal(true, { from: accounts[6] });

            await project.finalizeTimelineProposal({ from: devAccount });

            const timelineProposal = await project.getTimelineProposal.call();

            assert.equal(timelineProposal[3], false, "Timeline Proposal is still active.");

            const timelineHistoryLength = await project.getTimelineHistoryLength.call();

            assert.equal(timelineHistoryLength, 1, "Old timeline not pushed into timeline history.");

            const milestone = await project.getMilestone(0, false);

            assert.equal(milestone[0], "Milestone 2", "Pending timeline not moved into active timeline.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("dev cannot finalize timeline proposal if proposal is not active", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await project.finalizeTimelineProposal({ from: devAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot finalize timeline proposal early with less than 75% support", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[3], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[4], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[5], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[6], value: 100 });

            await project.addMilestone("Milestone 2", "Milestone 2 description", 100, true, { from: devAccount });

            await project.proposeNewTimeline({ from: devAccount });

            await project.voteOnTimelineProposal(true, { from: accounts[2] });
            await project.voteOnTimelineProposal(true, { from: accounts[3] });
            await project.voteOnTimelineProposal(true, { from: accounts[4] });
            await project.voteOnTimelineProposal(false, { from: accounts[5] });
            await project.voteOnTimelineProposal(false, { from: accounts[6] });

            await project.finalizeTimelineProposal({ from: devAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});

contract('ProjectMilestoneCompletionVoting', function(accounts) {
    let fundingService;
    let fundingServiceOwner;
    let devName;
    let devAccount;
    let project;
    let projectId;
    let projectTitle;
    let projectDescription;
    let projectAbout;
    let projectDevId;
    let projectContributionGoal;

    before(async () => {
        fundingService = await FundingService.deployed();

        devName = "Hyperbridge";
        fundingServiceOwner = accounts[0];
        devAccount = accounts[1];
        projectId = 0;

        await fundingService.createDeveloper(devName, { from: devAccount });
    });

    beforeEach(async () => {
        projectTitle = "Blockhub";
        projectDescription = "This is a description of Blockhub.";
        projectAbout = "These are the various features of Blockhub.";
        projectDevId = await fundingService.developerMap.call(devAccount);
        projectContributionGoal = 1000000;

        await fundingService.createProject(projectTitle, projectDescription, projectAbout, projectDevId, projectContributionGoal, {from: devAccount});

        projectId++;

        let projectAddress = await fundingService.projects.call(projectId);
        project = await Project.at(projectAddress);
    });

    it("cannot submit for milestone completion if current timeline is inactive", async () => {
        try {
            await project.submitMilestoneCompletion("Report", { from: devAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("cannot submit milestone completion if there is currently a vote on milestone completion", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(1, 1, { from: devAccount });

            await project.submitMilestoneCompletion("This milestone is done.", { from: devAccount });

            await project.submitMilestoneCompletion("This milestone is done.", { from: devAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("cannot submit milestone completion if there is a timeline proposal active", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await project.addMilestone("Milestone 2", "Milestone 2 description", 100, true, { from: devAccount });

            await project.proposeNewTimeline({ from: devAccount });

            await project.submitMilestoneCompletion("This milestone is done.", { from: devAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("can submit milestone completion", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await project.submitMilestoneCompletion("This milestone is done.", { from: devAccount });

            const milestoneCompletionSubmission = await project.getMilestoneCompletionSubmission.call();

            assert.equal(milestoneCompletionSubmission[4], true, "Milestone Completion Submission is not active.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("contributor can vote on milestone completion", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: 100 });

            await project.submitMilestoneCompletion("This milestone is done.", { from: devAccount });

            await project.voteOnMilestoneCompletion(true, { from: accounts[2] });

            const userHasVoted = await project.hasVotedOnMilestoneCompletion.call({ from: accounts[2] });

            assert.equal(userHasVoted, true, "User vote not registered.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-contributor cannot vote on milestone completion", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: 100 });

            await project.submitMilestoneCompletion("This milestone is done.", { from: devAccount });

            await project.voteOnMilestoneCompletion(true, { from: accounts[3] });

            assert.fail();
        } catch (e) {
            console.log(e.message);
            const userHasVoted = await project.hasVotedOnMilestoneCompletion.call({ from: accounts[3] });

            assert.equal(userHasVoted, false, "User vote was registered incorrectly.");
        }
    });

    it("developer can finalize milestone completion early with over 75% support", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[3], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[4], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[5], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[6], value: 100 });

            await project.submitMilestoneCompletion("This milestone is done.", { from: devAccount });

            await project.voteOnMilestoneCompletion(true, { from: accounts[2] });
            await project.voteOnMilestoneCompletion(true, { from: accounts[3] });
            await project.voteOnMilestoneCompletion(true, { from: accounts[4] });
            await project.voteOnMilestoneCompletion(true, { from: accounts[5] });
            await project.voteOnMilestoneCompletion(true, { from: accounts[6] });

            await project.finalizeMilestoneCompletion({ from: devAccount });

            const milestoneCompletionSubmission = await project.getMilestoneCompletionSubmission.call();

            assert.equal(milestoneCompletionSubmission[4], false, "Milestone Completion Submission is still active.");

            const milestone = await project.getMilestone(0, false);

            assert.equal(milestone[3], true, "Milestone not marked as complete.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("dev cannot finalize milestone completion submission if proposal is not active", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await project.finalizeMilestoneCompletion({ from: devAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot finalize milestone completion submission early with less than 75% support", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 100, false, { from: devAccount });
            await project.addTier(1000, 500, 10, "Rewards!", { from: devAccount });
            await project.finalizeTiers({ from: devAccount });

            await fundingService.submitProjectForReview(projectId, projectDevId, { from: devAccount });

            await fundingService.contributeToProject(projectId, { from: accounts[2], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[3], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[4], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[5], value: 100 });
            await fundingService.contributeToProject(projectId, { from: accounts[6], value: 100 });

            await project.submitMilestoneCompletion({ from: devAccount });

            await project.voteOnMilestoneCompletion(true, { from: accounts[2] });
            await project.voteOnMilestoneCompletion(true, { from: accounts[3] });
            await project.voteOnMilestoneCompletion(true, { from: accounts[4] });
            await project.voteOnMilestoneCompletion(false, { from: accounts[5] });
            await project.voteOnMilestoneCompletion(false, { from: accounts[6] });

            await project.finalizeMilestoneCompletion({ from: devAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
