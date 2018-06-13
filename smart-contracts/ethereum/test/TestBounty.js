const FundingService = artifacts.require("FundingService");
const Project = artifacts.require("Project");
const Bounty = artifacts.require("Bounty");

contract('Bounty', (accounts) => {

    let bountyDeveloper;
    let bountyName;
    let bountyDescription;
    let bountyLink;
    let bountyValue;
    let isComplete;

    before(async () => {
       bountyInstance = await Bounty.deployed();

       bountyDeveloper = accounts[0];
    });

    it("should be initialized with the right parameters", async () => {
        try {
            let testBountyName = "Maple";
            let testBountyDescription = "Greatest Bug In Existence";
            let testBountyLink = "http://dailyhive.com";
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
            assert.equal(this.balance, web3.utils.toWei("0", "ether"), "There are Ethers in the contract already");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to set bounty", async () => {
        try {

            await bountyInstance.setBountyValue({from: bountyDeveloper, value: web3.utils.toWei(10, "ether")});
            console.log(bountyValue);

            assert.equal(await bountyValue,10000000000000000000,"Bounty Value is Wrong");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
})