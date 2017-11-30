pragma solidity ^0.4.11;

contract MiningEquityDistributor {
  // Owners of the mining operation.
  address constant juan = 0x8E3c250aFC162Ec973B8190238F20F3D69f291f9;
  address constant rafael = 0xDaE2aC6792D6D9aCb3D05823C23625cb91b74c79;

  function MiningOperation() public pure {
  }

  function getContractBalance() public view returns (uint) {
    require(msg.sender == juan || msg.sender == rafael);
    return this.balance;
  }

  function withdrawContractBalance() public {
    require(msg.sender == juan || msg.sender == rafael);
    uint rebalanceAmount = this.balance/2;
    if (rebalanceAmount != 0) {
        juan.transfer(rebalanceAmount);
        rafael.transfer(rebalanceAmount);
    }
  }

  function() payable { }

  function terminateContract() public {
    require(msg.sender == juan || msg.sender == rafael);
    selfdestruct(juan);
  }
}
