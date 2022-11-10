// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("SS", "ss") {
        _mint(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 1000);
        _mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,1000);
    }
}
