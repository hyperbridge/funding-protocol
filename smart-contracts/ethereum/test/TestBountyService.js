/**
 * Testing Bounty Service Smart Contract
 * 
 * Work Flow for creating a Bounty:
 * 1. Deploy Contract
 * 2. Create Developer
 * 3. Create Bounty - send money to the contract
 * 4. Wait for Bounty Hunter to submit reports
 * 5. Check the bounty's reports
 * 6. Approve the bounty reports using the bounty hunters address
 * 7. Close the bounty
 * 8. Release the bounty
 * 
 * Coverage of the test: 
 * - Only bounty developer can close the bounty
 * - Only bounty developer can release the bounty
 */



const BountyService = artifacts.require("BountyService");
const StringUtils = artifacts.require("strings");

const ganache = require("ganache-cli");
const Web3 = require("web3");
const web3 = new Web3(ganache.provider());

contract('BountyService', (accounts) => {
    
    let bountyDeveloper = accounts[0];
    let bountyHunter1 = accounts[1];
    let bountyHunter2 = accounts[2];
    let bountyHunter3 = accounts[3];
    let imposterDeveloper = accounts[4];

    let bountyValue = 5000000000000000000;
    let bountyEmpty = 0;

    before(async () => {
        bountyService = await BountyService.deployed();   
        
        await bountyService.createDeveloper("Maple", {from: bountyDeveloper});
        await bountyService.createDeveloper("Imposter Maple", {from: imposterDeveloper});
        
    });

    it("Check if bounty Developer and imposter Developer exist", async () => {
        try {
            const createdDeveloper = await bountyService.developers.call(1);
            const createdImposterDeveloper = await bountyService.developers.call(2);

            assert.equal(await bountyService.owner.call(), bountyDeveloper, "Bounty Developer is incorrect or does not exist yet");
            assert.equal(await createdDeveloper[1], bountyDeveloper, "Bounty Developer address is incorrect or does not exist yet");
            assert.equal(await createdDeveloper[2], "Maple", "Bounty Developer name is incorrect");
            
            assert.equal(await createdImposterDeveloper[1], imposterDeveloper, "Imposter Bounty Developer address is incorrect or does not exist yet");
            assert.equal(await createdImposterDeveloper[2], "Imposter Maple", "Imposter Bounty Developer name is incorrect");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("Should be able to create bounty through bountyDeveloper", async () => {
        try {
            await bountyService.createBounty(1, "0xef55bfac4228981e850936aaf042951f7b146e41", "xiaxia", "Test bug description for Maple", "http://dailyhive.com", {from: bountyDeveloper, value: web3.utils.toWei("5", "ether")});
            const createdBounty = await bountyService.bountyCollection.call(0);
            assert.equal(await bountyService.bountyIdCounter.call(), 1, "BountyIdCounter did not increment");
            assert.equal(await bountyService.getBountyValue.call(0), bountyValue, "Bounty Value is not correct or bounty is not created");
            assert.equal(await createdBounty[1], "0xef55bfac4228981e850936aaf042951f7b146e41", "Target ID is wrong");
            assert.equal(await createdBounty[2], bountyDeveloper, "Developer of the bounty is wrong");
            assert.equal(await createdBounty[3], "xiaxia", "Bounty Name is wrong");
            assert.equal(await createdBounty[4], "Test bug description for Maple", "Bounty Description is wrong");
            assert.equal(await createdBounty[5], "http://dailyhive.com", "Bounty Link is wrong");
            assert.equal(await createdBounty[7], false, "Bounty IsComplete is true(supposed to be false)");
            

        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    //* VM Revert should happen and does happen. UnComment this block to test */
    // it("Imposter Developer should not be able close bounty", async () => {
    //     try {
    //         await bountyService.closeBounty(0,1, {from: imposterDeveloper});
    //         const createdBounty = await bountyService.bountyCollection.call(0);
    //         assert.equal(await createdBounty[7], false, "Bounty IsComplete is true(supposed to be false)");            
    //     } catch (e) {
    //         console.log(e.message);
    //         assert.fail();
    //     }
    // });


    //* VM Revert should happen and does happen. UnComment this block to test */
    // it("Imposter Developer should not be able release bounty", async () => {
    //     try {
    //         await bountyService.releaseBounty(0,1, {from: imposterDeveloper});
    //         assert.equal(await bountyService.getBountyValue.call(0), bountyValue, "Bounty Value is not correct or bounty is not created");
    //     } catch (e) {
    //         console.log(e.message);
    //         assert.fail();
    //     }
    // });

    it("Should be able to submit three bounty reports from three different addresses", async () => {
        try {
            await bountyService.submitBountyReport(0, "Test Submit Report: Look at 000", {from:bountyHunter1});
            await bountyService.submitBountyReport(0, "Test Submit Report: Look at 111", {from:bountyHunter2});
            await bountyService.submitBountyReport(0, "Test Submit Report: Look at 222", {from:bountyHunter3});
            assert.equal(await bountyService.getReportsforBounty.call(0),"#REPORT#Test Submit Report: Look at 000#REPORT#Test Submit Report: Look at 111#REPORT#Test Submit Report: Look at 222", {from: bountyDeveloper}, "Bounty Report Collection for this bounty is wrong");
            assert.equal(await bountyService.bountyHunterReportMap.call(0,0), bountyHunter1, "Bounty Hunter 1 Addr for this report is wrong");
            assert.equal(await bountyService.bountyHunterReportMap.call(0,1), bountyHunter2, "Bounty Hunter 2 Addr for this report is wrong");
            assert.equal(await bountyService.bountyHunterReportMap.call(0,2), bountyHunter3, "Bounty Hunter 3 Addr for this report is wrong");
            
            assert.equal(await bountyService.bountyReportMap.call(0,0), "Test Submit Report: Look at 000", "Bounty Hunter 1 Report is wrong");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("Should be able to approve Bounty Hunters", async () => {
        try {
            var hunterAddr1 = await bountyService.bountyHunterReportMap.call(0,0);
            var hunterAddr2 = await bountyService.bountyHunterReportMap.call(0,1);
            var hunterAddr3 = await bountyService.bountyHunterReportMap.call(0,2);
            var hunterAddrArray = String([hunterAddr1,hunterAddr2,hunterAddr3]);
            await bountyService.approveBountyHunter(0,bountyHunter1, {from: bountyDeveloper});
            await bountyService.approveBountyHunter(0,bountyHunter2, {from: bountyDeveloper});
            await bountyService.approveBountyHunter(0,bountyHunter3, {from: bountyDeveloper});
            assert.equal(String(await bountyService.getApprovedBountyHunters.call(0)), hunterAddrArray, "Approved Hunters are incorrect");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        };
    });

    //* VM Revert should happen and does happen. UnComment this block to test */
    // it("Bounty Hunter should not be able to approve an address", async () => {
    //     try {
    //         var hunterAddr1 = await bountyService.bountyHunterReportMap.call(0,0);
    //         await bountyService.approveBountyHunter(0,bountyHunter1, {from: bountyHunter1});
    //     } catch (e) {
    //         console.log(e.message);
    //         assert.fail(); 
    //     };
    // });

    it("Should be able to close the bounty", async () => {
        try {          
            await bountyService.closeBounty(0,1, {from: bountyDeveloper});
            const createdBounty = await bountyService.bountyCollection.call(0);  
            assert.equal(await createdBounty[7], true, "Bounty IsComplete is true(supposed to be false)");            
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // Releases funds but there are left over wei from the division
    // Need to use toNumber() because web3 passes back a big number
    it("Should be able to release funds from the contract", async () => {
        try {
            var bountyLeftover = bountyValue % 3;            
            await bountyService.releaseBounty(0,1, {from: bountyDeveloper});
            console.log((await bountyService.getBountyValue.call(0)).toNumber());
            assert.equal((await bountyService.getBountyValue.call(0)).toNumber(), bountyLeftover, "Bounty value is not equal to zero");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });


    //Test: Create another Bounty, Test sending random funds to contract(fallback)



    
})