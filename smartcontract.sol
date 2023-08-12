pragma solidity ^0.8.0;
import "https://github.com/molecule-protocol/molecule-core/blob/main/src/v2/interfaces/IMoleculeController.sol";
import "./MyCustomController.sol";
contract Contract {
    MyCustomController public myCustomController;
    IMoleculeController public moleculeGeneralSanctionController;
    uint[] public regionalIds;
    constructor(MyCustomController _myCustomController, IMoleculeController _moleculeGeneralSanctionController) {
        myCustomController = _myCustomController;
        moleculeGeneralSanctionController = _moleculeGeneralSanctionController;
    }
    function addRegionalId(uint _regionalId) external {
        regionalIds.push(_regionalId);
    }
    function myFunction() external {
        require(moleculeGeneralSanctionController.check(regionalIds, msg.sender), "Address is sanctioned.");
        require(myCustomController.check(msg.sender), "Address is not authorized.");
        // Access allowed to function code here
    }
}

contract MicroEtherContract {
    address public owner;
    mapping(address => uint256) public userCreditScores;

    constructor() {
        owner = msg.sender;
        userCreditScores = 0;
    }
    modifier hasSufficientCredit(uint256 requiredScore) {
        require(userCreditScores[msg.sender] >= requiredScore, "Insufficient credit score");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function updateUserCreditScore(address user, uint256 newScore) external {
        require(msg.sender == owner, "Only the owner can update credit scores");
        userCreditScores[user] = newScore;
    }

    function performCreditCheckedAction(uint256 requiredScore) external hasSufficientCredit(requiredScore) {
        // Only users with sufficient credit score can execute this function
        // Perform the desired action here
    }

    function getCreditScore(address user) external view returns (uint256) {
        return userCreditScores[user];
    }

    function checkCreditEligibility(address user, uint256 requiredScore) external view returns (bool) {
        return userCreditScores[user] >= requiredScore;
    }

struct Owner {
    address payable ownerAddress;
    //add some attributes
}

struct Borrower {
    address payable userAddress;
    Loan[] loans;
    uint creditScore;
}

struct Guarantor {
    address payable guarantorAddress;
    Loan[] loans;
    uint creditScore;
   
}

struct User {
    address payable userAddress;

    Loan[] loansTaken;
    uint creditScore;
    Loan[] loansGuaranteed;

    uint successfulTLoansNum; //successful taken loans
    uint successfulVLoansNum; //successful guaranteed loans
}



struct Group {
    uint totalLoanAmount;
    uint membersCount;
    bool isPaying;
    Borrower[] members;
}

struct Loan {
    uint loanID;
    address borrowerAddress;
    uint amount;
    uint dueDate;
    uint groupID;
    bool paymentMethod; //true = once a month, false = in the end of duedate
}

function validate(uint loanID) {

}

function totalSumOfLoans(Borrower borrower) external view returns (uint256) {
        uint sum = 0;
       for (uint i=0; i<borrower.loans.length; i++){
        sum += borrower.loans[i];
       }
       return sum;
}

function checkCreditEligibility(address user, uint256 requiredScore) external view returns (bool) {
        return userCreditScores[user] >= requiredScore && ;
}

function applyForLoan(uint amount, uint dueDate, uint groupID, bool paymentMethod) {


}


}