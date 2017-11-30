
pragma solidity ^0.4.11;

contract MiningEquityDistributorV2 {
  //Owner
  struct Owner {
    address addr;
    uint ownershipFactor;
    uint currentBalance;
  }

  Owner[] owners;

  bool withdrawLock;

  function MiningOperation(address[] newOwners, uint[] ownershipFactor) public {
    for (uint i = 0; i < newOwners.length; i++)
      owners.push(
                  Owner(newOwners[i],
                        ownershipFactor[i],
                        0)
                  );
  }


  function withdrawContractBalance() public payable {
    require(isOwner());
    require(withdrawLock);
    withdrawLock = false;
    uint availableFunds = contractAvailableFunds();
    for (uint i = 0; i < owners.length; i++){
      uint amountToTransfer = owners[i].currentBalance;
      amountToTransfer += availableFunds / owners[i].ownershipFactor;
      owners[i].currentBalance = 0;
      owners[i].addr.transfer(amountToTransfer);
    }
    withdrawLock = true;
  }

  function reportExpense(uint expenseAmount) public {
    require(isOwner());
    require(expenseAmount <= contractAvailableFunds());
    for (uint i = 0; i < owners.length; i++){
      if (owners[i].addr == msg.sender) {
        owners[i].currentBalance += expenseAmount;
      }
    }
  }

  function isOwner() private view returns (bool) {
    for (uint i = 0; i < owners.length; i++)
      if (owners[i].addr == msg.sender)
        return true;
    return false;
  }

  function contractAvailableFunds() private view returns (uint) {
    uint availableBalance = this.balance;
    for (uint i = 0; i < owners.length; i++)
      if (owners[i].addr == msg.sender)
        availableBalance -= owners[i].currentBalance;
    return availableBalance;
  }

  function() public payable { }

  /* function terminateContract() public { */
  /*   require(msg.sender == juan || msg.sender == rafael); */
  /*   selfdestruct(juan); */
  /* } */
}
