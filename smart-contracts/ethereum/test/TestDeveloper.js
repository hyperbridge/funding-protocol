const Developer = artifacts.require("Developer");

contract('Developer', function(accounts) {
    let developer;

    beforeEach(function() {
        return Developer.deployed().then(function(instance) {
            developer = instance;
        });
    });

    it("should deploy a developer contract with appropriate owner and name", function() {
        let owner;
        let name;

        developer.owner.call().then(function(devOwner) {
            owner = devOwner;
            return developer.name.call();
        }).then(function(devName) {
            name = devName;

            assert.ok(developer.address);
            const expectedOwner = accounts[0];
            const expectedName = "Hyperbridge";
            assert.equal(owner, expectedOwner, "Owner of contract was not the creator.");
            assert.equal(name, expectedName, "Incorrect contract name.");
        });
    });
});
