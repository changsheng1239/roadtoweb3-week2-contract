//SPDX-License-Identifier: Unlicense

// contracts/BuyMeACoffee.sol
pragma solidity ^0.8.0;

// Switch this to your own contract address once deployed, for bookkeeping!
// Example Contract Address on Goerli: 0xDBa03676a2fBb6711CB652beF5B7416A53c1421D

contract BuyMeACoffee {
    // Event to emit when a Memo is created.
    event NewMemo(
        address indexed from,
        uint256 timestamp,
        string coffeeSize,
        string name,
        string message
    );

    // Memo struct.
    struct Memo {
        address from;
        uint256 timestamp;
        string coffeeSize;
        string name;
        string message;
    }

    // Address of contract deployer. Marked payable so that
    // we can withdraw to this address later.
    address owner;
    address payable withdrawalAddress;
    // List of all memos received from coffee purchases.
    Memo[] memos;

    constructor() {
        // Store the address of the deployer as a payable address.
        // When we withdraw funds, we'll withdraw here.
        owner = msg.sender;
        withdrawalAddress = payable(msg.sender);
    }

    /**
     * @dev fetches all stored memos
     */
    function getMemos() public view returns (Memo[] memory) {
        return memos;
    }

    /**
     * @dev buy a coffee for owner (sends an ETH tip and leaves a memo)
     * @param _name name of the coffee purchaser
     * @param _message a nice message from the purchaser
     */
    function buyCoffee(string memory _name, string memory _message)
        public
        payable
    {
        // Must accept more than 0 ETH for a coffee.
        require(msg.value > 0, "can't buy coffee for free!");

        // Add the memo to storage!
        memos.push(
            Memo(msg.sender, block.timestamp, "regular", _name, _message)
        );

        // Emit a NewMemo event with details about the memo.
        emit NewMemo(msg.sender, block.timestamp, "regular", _name, _message);
    }

    function buyLargeCoffee(string memory _name, string memory _message)
        public
        payable
    {
        // Must accept more than 0 ETH for a coffee.
        require(
            msg.value == 0.003 * 10**18,
            "large coffee costs exactly 0.003 eth!"
        );

        // Add the memo to storage!
        memos.push(Memo(msg.sender, block.timestamp, "large", _name, _message));

        // Emit a NewMemo event with details about the memo.
        emit NewMemo(msg.sender, block.timestamp, "large", _name, _message);
    }

    /**
     * @dev send the entire balance stored in this contract to the owner
     */
    function withdrawTips() public {
        require(msg.sender == owner, "only owner is allowed to withdraw");
        require(withdrawalAddress.send(address(this).balance));
    }

    function getTipsBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function updateWithdrawalAddress(address _newWithdrawalAddress) public {
        require(
            msg.sender == owner,
            "only owner is allowed to update withdrawal address"
        );
        withdrawalAddress = payable(_newWithdrawalAddress);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getWithdrawalAddress() public view returns (address) {
        return withdrawalAddress;
    }
}
