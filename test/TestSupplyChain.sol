pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {
    uint public initialBalance = 1 ether;
    SupplyChain supply_chain = SupplyChain(DeployedAddresses.SupplyChain());

    function beforeAll() public {
        // add two items
        // sku 0
        bool itemAdded = supply_chain.addItem("first item", 1000);
        Assert.equal(itemAdded, true, "first item not added");
        // sku 1
        itemAdded = supply_chain.addItem("second item", 1000);
        Assert.equal(itemAdded, true, "second item not added");
    }

    // buyItem

    // test for failure if user does not send enough funds
    // test for purchasing an item that is not for Sale

    function buy() public {
        bool result;
        (result, ) = address(supply_chain).call.value(500)(abi.encodePacked(supply_chain.buyItem.selector, uint(0)));
        Assert.isFalse(result, "fail, not enough funds");

        supply_chain.buyItem.value(5000)(0);
        (, , , uint state, , ) = supply_chain.fetchItem(0);
        Assert.equal(state, 1, "fail, not sold");

        (result, ) = address(supply_chain).call.value(5000)(abi.encodePacked(supply_chain.buyItem.selector, uint(0)));
        Assert.isFalse(result, "error, already sold");
    }

    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    function ship() public {
        bool result;
        (result, ) = address(supply_chain).call(abi.encodePacked(supply_chain.shipItem.selector, uint(0)));
        Assert.isTrue(result, "fail, restricted to caller");
        (result, ) = address(supply_chain).call(abi.encodePacked(supply_chain.shipItem.selector, uint(1)));
        Assert.isFalse(result, "fail, already sold");
    }

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

    function receive() public {
        bool result;
        (, , , uint state, , ) = supply_chain.fetchItem(0);
        Assert.equal(state, 2, "error, not shipped.");
        (result, ) = address(supply_chain).call(abi.encodePacked(supply_chain.receiveItem.selector, uint(0)));
        Assert.isTrue(result, "fail, restricted to caller");
        (result, ) = address(supply_chain).call(abi.encodePacked(supply_chain.receiveItem.selector, uint(1)));
        Assert.isFalse(result, "error, not shipped");
    }

    function() external payable {}
}
