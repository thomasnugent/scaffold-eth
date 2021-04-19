pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = now + 30 seconds;
  
  bool public completed;
  
  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  function stake() public payable {
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);

    // // Refer to the contract as address(this)
    // if (block.timestamp <= deadline && address(this).balances >= threshold) {
    //   isActive = true;
    // }
  }

  function complete() public payable {
    // completed = true;
  }

  // TODO
  function withdraw() public {}
  //   require(block.timestamp > deadline, "deadline hasn't passed yet");
  //   require(isActive == false, "Contract is active");
  //   require(balances[msg.sender] > 0, "You haven't deposited");
    
  //   uint256 amount = balances[msg.sender];
  //   balances[msg.sender] = 0;
  //   msg.sender.transfer(amount);
  // }


  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  event Stake(address, uint256);

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balances}()` to send all the value



  // if the `threshold` was not met, allow everyone to call a `withdraw()` function



  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


}
