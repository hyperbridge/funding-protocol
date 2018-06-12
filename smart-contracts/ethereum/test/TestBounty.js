const FundingService = artifacts.require("FundingService");
const Project = artifacts.require("Project");
const Bounty = artifacts.require("Bounty");

contract('Bounty', (accounts) => {

    let developer;
    let bountyName;
    let bountyDescription;
    let bountyLink;
    let bountyValue;
    let isComplete;

    beforeEach(async () => {
        bountyInstance = await Bounty.deployed("Maple", "Greatest Bug In Existence", "http://dailyhive.com")

    })

    it("should be able to set bounty", async () => {
        try {
            let bountyDeveloper = accounts[0];

            await bountyInstance.setBountyValue({from: bountyDeveloper, value: web3.utils.toWei(10)});

            assert.equal(bountyValue,10000000000000000000,"Bounty Value is Wrong");
        }
    })
})