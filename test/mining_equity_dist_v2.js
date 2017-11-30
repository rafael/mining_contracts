var MiningOperation = artifacts.require("MiningOperation");

contract('MiningOperation', function(accounts) {
  it("creates new contract with provided owners in migration", function() {
    var expectedOwners = [accounts[0], accounts[1]];
    MiningOperation.defaults({from: accounts[0]});
    return MiningOperation.deployed().then(instance => {
      return instance.contractOwners.call();
    }).then(contractOwners => {
      assert.equal(contractOwners[0], expectedOwners[0], "First owner doesn't match the address");
      assert.equal(contractOwners[1], expectedOwners[1], "Second owner doesn't match the address");
    });
  });
  it("behaves like a proper contract", function() {
    var expectedOwners = [accounts[0], accounts[1]];
    MiningOperation.defaults({from: accounts[0]});
    var mining;
    accountOneOriginalAmount = web3.eth.getBalance(accounts[0]);
    accountTwoOriginalAmount = web3.eth.getBalance(accounts[1]);
    depositAmount = 1000000000000000000;
    MiningOperation.deployed().then(function(instance) {
      mining = instance;
      web3.eth.sendTransaction({from: accounts[accounts.length-1],
                                to: mining.address,
                                value: depositAmount });
      return instance.ownerAvailalbeFunds.call();
    }).then(funds => {
      assert.equal(funds, depositAmount/2, "expected owner amount not matching");
      return mining.reportExpense.call(100);
    }).then(expenseReported => {
     assert.equal(expenseReported, true, "it should be able te expense report");
      return mining.ownerAvailalbeFunds.call();
     }).then(availableFundsAfterExpense => {
       assert.equal(availableFundsAfterExpense.toString(10), depositAmount/2, "reflects amount expese report");
       mining.withdrawContractBalance();
     });
    assert.equal(web3.eth.getBalance(accounts[0]).toString(), accountOneOriginalAmount + depositAmount/2, "final balance is the expected one");
    return assert.equal(web3.eth.getBalance(accounts[1]).toString(), accountTwoOriginalAmount + depositAmount/2 + 1000, "final balance is the expected one");
  });
});
