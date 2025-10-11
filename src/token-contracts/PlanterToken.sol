// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PlanterToken is ERC20, Ownable {
    address public planterAddress;
    constructor(address _planter) Ownable(msg.sender) ERC20("PlanterToken", "PRT") {
        planterAddress = _planter;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function getPlanterAddress() external view returns (address) {
        return planterAddress;
    }
}
