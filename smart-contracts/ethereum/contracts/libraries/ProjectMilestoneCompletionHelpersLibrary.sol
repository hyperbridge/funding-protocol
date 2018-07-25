pragma solidity ^0.4.24;

import "./storage/ProjectStorageAccess.sol";
import "./storage/ContributionStorageAccess.sol";
import "../FundingVault.sol";
import "../FundingStorage.sol";
import "./ProjectTimelineHelpersLibrary.sol";

library ProjectMilestoneCompletionHelpersLibrary {

    using ProjectStorageAccess for address;
    using ContributionStorageAccess for address;
    using ProjectTimelineHelpersLibrary for address;
    
    function succeedMilestoneCompletion(address _fundingStorage, uint _projectId) external {
        uint activeIndex =_fundingStorage.getActiveMilestoneIndex(_projectId);
       _fundingStorage.setTimelineMilestoneIsComplete(_projectId, activeIndex, true);

        // Set milestone completion submission to inactive
       _fundingStorage.setMilestoneCompletionSubmissionIsActive(_projectId, false);

        // Update completedMilestones, remove any pending milestones, and add the completed milestones + current active
        // milestone to the start of the pending timeline. This is to ensure that any future timeline proposals take
        // into account the milestones that have already released their funds.

        // Add current milestone to completed milestones list
        ProjectStorageAccess.Milestone memory activeMilestone =_fundingStorage.getTimelineMilestone(_projectId, activeIndex);

       _fundingStorage.pushCompletedMilestone(_projectId, activeMilestone.title, activeMilestone.description, activeMilestone.percentage, activeMilestone.isComplete);

       _fundingStorage.moveCompletedMilestonesIntoPendingTimeline(_projectId);

        // Increment active milestone and release funds if this was not the last milestone
        if (activeIndex <_fundingStorage.getTimelineLength(_projectId) - 1) {
            // Increment the active milestone
           _fundingStorage.setActiveMilestoneIndex(_projectId, ++activeIndex);

            // Add currently active milestone to pendingTimeline
            ProjectStorageAccess.Milestone memory currentMilestone =_fundingStorage.getTimelineMilestone(_projectId, activeIndex);
           _fundingStorage.pushPendingTimelineMilestone(_projectId, currentMilestone.title, currentMilestone.description, currentMilestone.percentage, currentMilestone.isComplete);

           releaseMilestoneFunds(_fundingStorage, _projectId, activeIndex);
        }
    }

    function releaseMilestoneFunds(address _fundingStorage, uint _projectId, uint _index) public {
        uint fundsRaised = _fundingStorage.getProjectFundsRaised(_projectId);
        uint percentageToSend = _fundingStorage.getTimelineMilestonePercentage(_projectId, _index);
        uint amountToSend = fundsRaised * percentageToSend / 100;
        address developer = _fundingStorage.getProjectDeveloper(_projectId);
        FundingStorage fs = FundingStorage(_fundingStorage);
        FundingVault fv = FundingVault(fs.getContractAddress("FundingVault"));
        fv.withdrawEth(amountToSend, developer);
    }
}
