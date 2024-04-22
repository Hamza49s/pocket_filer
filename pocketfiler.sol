// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TwoPartyTransaction {
    address public partyA;
    address public partyB;
    uint public amount;
    address public contractOwner;
    uint public commissionRate;
    bool public partyAApproved;
    bool public partyBApproved;
    bool public fundsReleased;

    constructor(address _partyA, address _partyB, uint _amount, address _contractOwner, uint _commissionRate) {
        partyA = _partyA;
        partyB = _partyB;
        amount = _amount;
        contractOwner = _contractOwner;
        commissionRate = _commissionRate;
    }

    function approveTransaction() public {
        require(msg.sender == partyA || msg.sender == partyB, "Only parties involved can approve the transaction");
        if(msg.sender == partyA) {
            partyAApproved = true;
        }
        if(msg.sender == partyB) {
            partyBApproved = true;
        }
        if(partyAApproved && partyBApproved) {
            transferFunds();
        }
    }

    function transferFunds() private {
        require(!fundsReleased, "Funds already released");
        require(address(this).balance >= amount, "Insufficient funds in contract");
        payable(partyB).transfer(amount);
        fundsReleased = true;
        calculateAndDistributeCommission();
    }

    function calculateAndDistributeCommission() private {
        require(fundsReleased, "Funds not yet released");
        uint commissionAmount = (amount * commissionRate) / 100;
        payable(contractOwner).transfer(commissionAmount);
    }



}

contract TwoPartyTransactionFactory {
    address[] private deployedContracts;
    event ContractCreated(address indexed newContract);


   
     function createTwoPartyTransaction(address _partyA, address _partyB, uint _amount, address _contractOwner, uint _commissionRate) public returns (address) {
        address newContract = address(new TwoPartyTransaction(_partyA, _partyB, _amount, _contractOwner, _commissionRate));
        deployedContracts.push(newContract);
        emit ContractCreated(newContract);
        return newContract;
    }

    
}