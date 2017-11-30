
pragma solidity ^0.4.11;

contract MiningOperation {
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

  function reportExpense(uint expenseAmount) public returns (bool){
    require(isOwner());
    if (expenseAmount > contractAvailableFunds())
      return false;
    for (uint i = 0; i < owners.length; i++){
      if (owners[i].addr == msg.sender) {
        owners[i].currentBalance += expenseAmount;
        return true;
      }
    }
    return false;
  }

  function isOwner() internal view returns (bool) {
    for (uint i = 0; i < owners.length; i++)
      if (owners[i].addr == msg.sender)
        return true;
    return false;
  }

  function ownerAvailalbeFunds() public view returns (uint) {
    require(isOwner());
    for (uint i = 0; i < owners.length; i++)
      if (owners[i].addr == msg.sender)
        return owners[i].currentBalance + this.balance/owners[i].ownershipFactor;
  }


  function contractOwners() public view returns (address[] memory r) {
    require(isOwner());
    r = new address[](owners.length);
    for (uint i = 0; i < owners.length; i++)
      r[i] = owners[i].addr;
    return r;
  }

  function contractAvailableFunds() internal view returns (uint) {
    uint availableBalance = this.balance;
    for (uint i = 0; i < owners.length; i++)
      if (owners[i].addr == msg.sender)
        availableBalance -= owners[i].currentBalance;
    return availableBalance;
  }

  function() public payable { }

  function terminateContract() public {
    require(isOwner());
    selfdestruct(msg.sender);
  }
}
