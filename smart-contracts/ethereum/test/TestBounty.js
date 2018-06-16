const FundingService = artifacts.require("FundingService");
const Project = artifacts.require("Project");
const Bounty = artifacts.require("Bounty");

const ganache = require("ganache-cli");
const Web3 = require("web3");
const web3 = new Web3(ganache.provider());

contract('Bounty', (accounts) => {

    let bountyDeveloper = accounts[0];
    let bountyHunter = accounts[1];
    let imposterDeveloper = accounts[2];

    before(async () => {
       bountyInstance = await Bounty.deployed();
    });

    it("should be initialized with the right parameters", async () => {
        try {
            let testProjectAddress = "0xca35b7d915458ef540ade6068dfe2f44e8fa733c";
            let testBountyId = 1;
            let testBountyName = "Maple";
            let testBountyDescription = "Greatest Bug In Existence";
            let testBountyLink = "http://dailyhive.com";
            assert.equal(await bountyInstance.projectAddress.call(), testProjectAddress, "Project Address is wrong");
            assert.equal(await bountyInstance.bountyId.call(), testBountyId, "Bounty Id is wrong");
            assert.equal(await bountyInstance.bountyName.call(), testBountyName, "Bounty name is wrong");
            assert.equal(await bountyInstance.bountyDescription.call(), testBountyDescription, "Bounty description is wrong");
            assert.equal(await bountyInstance.bountyLink.call(), testBountyLink, "Bounty Link is wrong");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("Check if there are no ethers in the contract already", async () => {
        try {
            assert.equal(await bountyInstance.bountyValue.call(), 0, "There are Ethers in the contract already");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to set bounty", async () => {
        try {
            await bountyInstance.setBountyValue({from: bountyDeveloper, value: web3.utils.toWei("2", "ether")});
            assert.equal(await bountyInstance.bountyValue.call(),"2000000000000000000", "Bounty Value is Wrong");            
        
        } catch (e) {
            console.log(e.message);
            assert.fail();
        } 
    });


    it("Bounty Hunter should be able to make a report", async () => {
        try {
            await bountyInstance.makeReport("This is unacceptable", "https://hyperbridge.org/", { from: bountyHunter })
            assert.equal(await bountyInstance.viewBountyReport(bountyHunter),"This is unacceptable", "Bounty Hunter Report is wrong")
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("Bounty Developer should be able to release bounty funds", async () => {
        try {
            await bountyInstance.releaseBounty(bountyHunter, { from: bountyDeveloper })
            assert.equal(await bountyInstance.bountyValue.call(), 0, "The Bounty still has not been released")
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    })
})