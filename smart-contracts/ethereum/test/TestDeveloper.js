const Developer = artifacts.require("Developer");

contract('Developer', function(accounts) {
    it("should deploy a developer contract with appropriate owner and name", async () => {
        try {
            let developer = await Developer.deployed();

            let owner = await developer.owner.call();
            let name = await developer.name.call();

            assert.ok(developer.address);
            const expectedOwner = accounts[0];
            const expectedName = "Hyperbridge";
            assert.equal(owner, expectedOwner, "Owner of contract was not the creator.");
            assert.equal(name, expectedName, "Incorrect contract name.");
        } catch (e) {
            console.log(err);
            assert.fail();
        }
    });
});
