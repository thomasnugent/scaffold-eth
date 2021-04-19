pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 0.01 ether;  // NOTE easier for testing than 1 ether
  uint256 public deadline = now + 30 seconds;
  bool public completed;
  
  event Stake(address, uint256);
  
  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    completed = false;
 }

  function stake() public payable {
    // Only stake if we're within the deadline.
    // The requirement for `completed == false` shouldn't be necessary assuming `execute()` works properly.
    require(now <= deadline, "Deadline has already passed");
    require(completed == false, "Contract has already been completed");

    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // NOTE I don't think this was being called. Can be removed.
  // function complete() public payable {
  //   completed = true;
  // }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balances}()` to send all the value
  function execute() public {

    // We only want to execute if we haven't completed.
    require(completed == false, "Contract has already been completed");
    require(now >= deadline, "Deadline hasn't passed yet");
    require(address(this).balance >= threshold, "Threshold not reached");
    exampleExternalContract.complete{value: address(this).balance}();
    completed = true;  // Maybe move this before the line above, since it can take time
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw(address) public payable {

    // Attempt to execute first, in case it hasn't been called yet.
    // if (completed == false) {
    //   // this.execute();
    //   execute();

    //   // FIXME Transaction reverted: function call failed to execute

    // NOTE What happens if withdraw is called before the `exampleExternalContract.complete{value: address(this).balance}();` finishes?
    // Then execute() will have 2 calls to it...
    // NOTE If we do go over the threshold, you can't withdraw. Instead, execute() is called first and takes your stake.
    // }

    require(now >= deadline, "Deadline hasn't passed yet");
    // require(completed == true, "Contract has not been completed");
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

/* Questions / Concerns:
   
   * I could be using too many `require` calls instead of if statements
   * I've disallowed people from staking after the deadline
   * We are allowed to stake much more than the threshold
   * The `require` error messages can be misleading. e.g. with Lines 52-61 uncommented, withdraw can give "Threshold not reached" since it calls execute().
   * You can't withdraw until after deadline.
   * With Lines 52-61 commented out, one can withdraw even if we did reach the threshold. Ideally, execute() is called beforehand.
*/