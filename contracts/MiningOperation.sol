pragma solidity ^0.4.11;

contract MiningOperation {
  //Owner
  struct Owner {
    address addr;
    uint ownershipPercent;
    uint currentBalance;
  }

  Owner[] owners;

  bool withdrawLock;

  function MiningOperation(address[] newOwners, uint[] ownershipPercent) public {
    uint operationPercent = 0;
    withdrawLock = true;
    for (uint i = 0; i < newOwners.length; i++) {
      operationPercent += ownershipPercent[i];
      owners.push(
                  Owner(newOwners[i],
                        ownershipPercent[i],
                        0)
                  );
    }
    require(operationPercent == 100);
  }


  function withdrawContractBalance() public payable {
    require(isOwner());
    require(withdrawLock);
    withdrawLock = false;
    uint availableFunds = contractAvailableFunds();
    for (uint i = 0; i < owners.length; i++){
      uint amountToTransfer = owners[i].currentBalance;
      amountToTransfer += availableFunds / percentageDenominator(owners[i].ownershipPercent);
      owners[i].currentBalance = 0;
      owners[i].addr.transfer(amountToTransfer);
    }
    withdrawLock = true;
  }

  function reportExpense(uint256 expenseAmount) public returns (bool){
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

  function substractExpense(uint256 expenseAmount) public returns (bool){
    require(isOwner());
    for (uint i = 0; i < owners.length; i++){
      if (owners[i].addr == msg.sender) {
        if (expenseAmount > owners[i].currentBalance)
          return false;
        owners[i].currentBalance -= expenseAmount;
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
        return owners[i].currentBalance + this.balance/percentageDenominator(owners[i].ownershipPercent);
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

  function percentageDenominator(uint ownership) internal pure returns (uint) {
    return 100/ownership;
  }

  function() public payable { }

  function terminateContract() public {
    require(isOwner());
    selfdestruct(msg.sender);
  }
}
