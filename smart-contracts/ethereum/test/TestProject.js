const FundingService = artifacts.require("FundingService");
const Project = artifacts.require("Project");

contract('Project', function(accounts) {
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

    it("should be able to add milestones", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 20, { from: devAccount });

            let pendingMilestoneLength = await project.getPendingTimelineMilestoneLength.call();
            assert.equal(pendingMilestoneLength.toNumber(), 1, "Pending milestone not added.");

            await project.addMilestone(milestoneTitle, milestoneDescription, 30, { from: devAccount });

            pendingMilestoneLength = await project.getPendingTimelineMilestoneLength.call();
            assert.equal(pendingMilestoneLength.toNumber(), 2, "Second pending milestone not added.");

            await project.addMilestone(milestoneTitle, milestoneDescription, 50, { from: devAccount });
            pendingMilestoneLength = await project.getPendingTimelineMilestoneLength.call();
            assert.equal(pendingMilestoneLength.toNumber(), 3, "Third pending milestone not added.");

            await project.finalizeTimeline({ from: devAccount });
            pendingMilestoneLength = await project.getPendingTimelineMilestoneLength.call();
            assert.equal(pendingMilestoneLength.toNumber(), 0, "Finalizing timeline did not remove pending milestones.");

            let timelineLength = await project.getTimelineMilestoneLength.call();
            assert.equal(timelineLength.toNumber(), 3, "Finalizing timeline did not move pending milestones into timeline.");

            let timelineHistoryLength = await project.getTimelineHistoryLength.call();
            assert.equal(timelineHistoryLength, 0, "Timeline was added to history when it shouldn't have been.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should reject wrong account from adding milestones", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 20, { from: accounts[2] });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should reject milestone with percentage > 100", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 101, { from: devAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should be able to edit a pending milestone", async () => {
        try {
            let milestoneTitle = "Milestone 1";
            let milestoneDescription = "Milestone description.";

            await project.addMilestone(milestoneTitle, milestoneDescription, 20, { from: devAccount });

            let milestone = await project.getPendingTimelineMilestone.call(0, { from: devAccount });

            assert.equal(milestone[0], milestoneTitle, "Title is wrong.");
            assert.equal(milestone[1], milestoneDescription, "Description is wrong.");
            assert.equal(milestone[2], 20, "Percentage is wrong.");

            let newTitle = "New Milestone";
            let newDescription = "New description";

            await project.editMilestone(0, newTitle, newDescription, 30, { from: devAccount });

            milestone = await project.getPendingTimelineMilestone.call(0, { from: devAccount });

            assert.equal(milestone[0], newTitle, "Title is wrong.");
            assert.equal(milestone[1], newDescription, "Description is wrong.");
            assert.equal(milestone[2], 30, "Percentage is wrong.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
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
