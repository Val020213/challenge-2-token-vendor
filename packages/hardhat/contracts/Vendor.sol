pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT
import "./YourToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error ERC20InsufficientBalance();
error VendorWithdrawFailed();
error VendorSellFailed();

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event Withdraw(address owner, uint256 amount);
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() external payable {
        // uint256 tokensToBuy = (msg.value * tokensPerEth) / 1 ether;
        uint256 tokensToBuy = (msg.value * tokensPerEth);

        if (yourToken.balanceOf(address(this)) < tokensToBuy) {
            revert ERC20InsufficientBalance();
        }

        yourToken.transfer(msg.sender, tokensToBuy);
        emit BuyTokens(msg.sender, msg.value, tokensToBuy);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{ value: balance }("");
        if (!success) {
            revert VendorWithdrawFailed();
        }
        emit Withdraw(msg.sender, balance);
    }

    function sellTokens(uint256 _amount) external {
        // uint256 ethToTransfer = (_amount * 1 ether) / tokensPerEth;
        uint256 ethToTransfer = _amount / tokensPerEth;

        if (address(this).balance < ethToTransfer) {
            revert ERC20InsufficientBalance();
        }

        yourToken.transferFrom(msg.sender, address(this), _amount);
        (bool success, ) = msg.sender.call{ value: ethToTransfer }("");
        if (!success) {
            revert VendorSellFailed();
        }
        emit SellTokens(msg.sender, _amount, ethToTransfer);
    }
}
