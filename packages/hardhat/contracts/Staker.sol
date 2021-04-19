pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 0.01 ether;  // NOTE easier for testing than 30s
  uint256 public deadline = now + 120 seconds;  // NOTE easier for testing than 30s

  bool public completed;
  
  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  function stake() public payable {
    // Only stake if we're within the deadline and hasn't been completed.
    // This keeps the implementation clean
    require(completed == false, "Contract has already been completed");
    require(now <= deadline, "Deadline has already passed");

    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  function complete() public payable {
    completed = true;
    // TODO send full balance? Or is it assumed this happens
    // NOTE this does mean we can stake much more than the threshold
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  event Stake(address, uint256);

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balances}()` to send all the value
  function execute() public {

    // Could put the conditions in if statement in `require` statements for better error messages too
    require(completed == false, "Contract has already been completed");

    if (now <= deadline && address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    }
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public {
    require(now > deadline, "Deadline hasn't passed yet");
    require(completed == true, "Contract has not been completed");
    require(balances[msg.sender] > 0, "You haven't deposited");
    
    // Must set balances to 0 for this sender before transferring
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(amount);
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    return now > deadline ? 0 : deadline - now;
  }
}
