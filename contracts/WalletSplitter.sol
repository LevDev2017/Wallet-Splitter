// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WalletSplitter is ReentrancyGuard {

    address payable private owner0; // gets 2/5 of fees + dust
    address payable private owner1; // gets 1/5 of fees
    address payable private owner2; // gets 1/5 of fees
    address payable private owner3; // gets 1/5 of fees

    constructor(address payable _owner0, address payable _owner1, address payable _owner2, address payable _owner3) {
        owner0 = _owner0;
        owner1 = _owner1;
        owner2 = _owner2;
        owner3 = _owner3;
    }

    // to recieve native token 
    receive() external payable {}

    function withdraw() public payable nonReentrant {
        // get balance of native token
        uint256 balance = address(this).balance;
        // calculate fees
        uint256 oneFifth = SafeMath.div(balance, 5);
        uint256 twoFifth = SafeMath.mul(2, oneFifth);
        uint256 dust     = SafeMath.mod(balance, 5);
        // owner0 gets 2/5 of fees + dust
        owner0.transfer(twoFifth + dust);
        // owner1,2,3 gets 1/5 fees
        owner1.transfer(oneFifth);
        owner2.transfer(oneFifth);
        owner3.transfer(oneFifth);
    }

    function withdrawToken(address _contract) public nonReentrant{
        IERC20 erc20 = IERC20(_contract);
        // get balance of tokens
        uint256 balance = erc20.balanceOf(address(this));
        // calculate fees
        uint256 oneFifth = SafeMath.div(balance, 5);
        uint256 twoFifth = SafeMath.mul(2, oneFifth);
        uint256 dust     = SafeMath.mod(balance, 5);
        // owner0 gets 2/5 of fees + dust
        erc20.transfer(owner0, (twoFifth + dust));
        // owner1,2,3 gets 1/5 fees
        erc20.transfer(owner1, oneFifth);
        erc20.transfer(owner2, oneFifth);
        erc20.transfer(owner3, oneFifth);
    }

    function updateOwner(address payable _newOwner) public returns(bool) {
        if (msg.sender == owner0) {
            owner0 = _newOwner;
            return true;
        }
        if (msg.sender == owner1) {
            owner1 = _newOwner;
            return true;
        }
        if (msg.sender == owner2) {
            owner2 = _newOwner;
            return true;
        }
        if (msg.sender == owner3) {
            owner3 = _newOwner;
            return true;
        }
        return false;
    }

}