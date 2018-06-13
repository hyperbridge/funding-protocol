const FundingVault = artifacts.require("FundingVault");

const BigNumber = web3.BigNumber;


const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();


/**
 * @param FundingServiceAddress  is only random address for now since we are
  building vault as an independnet entity
 */
contract('FundingVault', function([owner, fundingServiceAddress, randomAddress]) {

    let fundingVault;
    let value;

    before(async () => {
          fundingVault = await FundingVault.new(owner, fundingServiceAddress);
          value = 1000;
    });

    it("should deploy a FundingVault contract", async () => {
        fundingVault.should.not.be.undefined;
    });

    it("should allow fundingService contract to deposite ETH", async () => {

        await fundingVault.depositeETH({value: value, from: fundingServiceAddress}).should.be.fulfilled;

        balance = await fundingVault.getBalance();
        balance.should.be.bignumber.equal(value);
    });

    it("should rejects non fundingService address from depositing ETH", async () => {

        await fundingVault.depositeETH({ value: value, from: randomAddress}).should.be.rejectedWith('revert');
    });

    it("should allow fundingService contract to withdraw ETH", async () => {
        oldBalance = await fundingVault.getBalance({from: randomAddress});
        await fundingVault.withdrawETH(value, fundingServiceAddress, {from: fundingServiceAddress}).should.be.fulfilled;

        newBalance = await fundingVault.getBalance({from: randomAddress});
        newBalance.should.be.bignumber.equal(oldBalance-value);
    });

    it("should rejects non fundingService address from withdrawing ETH", async () => {
        await fundingVault.withdrawETH(value, randomAddress, {from: randomAddress}).should.be.rejected;
    });

    it("should allow owner to set fundingService contract address", async () => {
        await fundingVault.setFundingServiceContract(randomAddress, {from: owner}).should.be.fulfilled;
    });

    it("should rejects none owner user from setting fundingService contract address", async () => {
        await fundingVault.setFundingServiceContract(randomAddress, {from: randomAddress}).should.be.rejected;
    });

});
