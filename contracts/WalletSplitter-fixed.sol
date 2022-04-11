// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract WalletSplitter is ReentrancyGuard {

    address private owner0; // gets 2/5 of fees + dust
    address private owner1; // gets 1/5 of fees
    address private owner2; // gets 1/5 of fees
    address private owner3; // gets 1/5 of fees

    constructor(address _owner0, address _owner1, address _owner2, address _owner3) {
        require(_owner0 != address(0) && !Address.isContract(_owner0), "Not allowed zero address and contract");
        require(_owner1 != address(0) && !Address.isContract(_owner1), "Not allowed zero address and contract");
        require(_owner2 != address(0) && !Address.isContract(_owner2), "Not allowed zero address and contract");
        require(_owner3 != address(0) && !Address.isContract(_owner3), "Not allowed zero address and contract");

        owner0 = _owner0;
        owner1 = _owner1;
        owner2 = _owner2;
        owner3 = _owner3;
    }

    // to recieve native token 
    receive() external payable {}

    function withdraw() external payable nonReentrant {
        // get balance of native token
        uint256 balance = address(this).balance;
        // calculate fees
        uint256 oneFifth = SafeMath.div(balance, 5);
        uint256 twoFifth = SafeMath.mul(2, oneFifth);
        uint256 dust     = SafeMath.mod(balance, 5);
        // owner0 gets 2/5 of fees + dust
        payable(owner0).transfer(twoFifth + dust);
        // owner1,2,3 gets 1/5 fees
        payable(owner1).transfer(oneFifth);
        payable(owner2).transfer(oneFifth);
        payable(owner3).transfer(oneFifth);
    }

    function withdrawToken(address _contract) external nonReentrant{
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

    function updateOwner(address _newOwner) external returns(bool) {
        require(_newOwner != address(0) && !Address.isContract(_newOwner), "Not allowed zero address and contract");

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