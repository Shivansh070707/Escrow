// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Escrow {
    enum State {
        Not_Initialized,
        Order_Placed,
        Order_Submitted,
        Order_Delivered,
        Confirmed_delivery,
        denied_delivery,
        finished
    }
    State public currentState;

    uint256 public price;
    IERC20 token;

    address public buyer;
    address public seller;
    uint256 deliveryTime;
    uint256 withdrawTime;

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function!");
        _;
    }
    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this function!");
        _;
    }

    constructor(
        address _buyer,
        address _seller,
        uint256 _price,
        address Token
    ) {
        buyer = _buyer;
        seller = _seller;
        price = _price;
        token = IERC20(Token);
        currentState = State.Not_Initialized;
    }

    function BuyerSendPayment() public onlyBuyer {
        require(
            IERC20(token).balanceOf(msg.sender) >= price,
            "Insufficient Balance"
        );
        require(currentState == State.Not_Initialized);
        currentState = State.Order_Placed;
        IERC20(token).transferFrom(buyer, address(this), price);
    }

    function confirmOrder() public onlySeller {
        require(
            currentState == State.Order_Placed,
            "Buyer hasn't Placed any order yet"
        );
        currentState = State.Order_Submitted;
    }

    function deliver() public onlySeller {
        require(currentState == State.Order_Submitted);
        currentState = State.Order_Delivered;
    }

    function confirmDelivery(bool _isDelivered) public onlyBuyer {
        require(
            currentState == State.Order_Delivered,
            "Cannot confirm delivery"
        );
        if (_isDelivered) {
            currentState = State.Confirmed_delivery;
            deliveryTime = block.timestamp;
            withdrawTime= block.timestamp + 3 seconds;
        } else {
            currentState = State.denied_delivery;
        }
    }

    function claimFunds() public onlySeller {
        require(
            currentState == State.Confirmed_delivery,
            "Cannot withdraw at this stage"
        );
        require(block.timestamp >= withdrawTime, "Cannot claim before 3 days");
        IERC20(token).transfer(seller, price);
        currentState = State.finished;
    }
}
