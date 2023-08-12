pragma solidity ^0.8.0;
import "https://github.com/molecule-protocol/molecule-core/blob/main/src/v2/interfaces/IMoleculeController.sol";
//import "./MyCustomController.sol";

contract MicroEtherContract {
   // MyCustomController public myCustomController;
    IMoleculeController public moleculeGeneralSanctionController;
    uint[] public regionalIds;
    constructor(//MyCustomController _myCustomController, 
    IMoleculeController _moleculeGeneralSanctionController) {
        //myCustomController = _myCustomController;
        moleculeGeneralSanctionController = _moleculeGeneralSanctionController;
    }
    function addRegionalId(uint _regionalId) external {
        regionalIds.push(_regionalId);
    }
    function myFunction() external {
        require(moleculeGeneralSanctionController.check(regionalIds, msg.sender), "Address is sanctioned.");
        //require(myCustomController.check(msg.sender), "Address is not authorized.");
        // Access allowed to function code here
    }






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

/*struct Borrower {
    address payable userAddress;
    Loan[] loans;
    uint creditScore;
}

struct Guarantor {
    address payable guarantorAddress;
    Loan[] loans;
    uint creditScore;
   
}*/

struct User {
    address payable userAddress;

    Loan[] loansTaken;
    int256 creditScore;
    Loan[] loansGuaranteed;

    uint successfulTLoansCount; //successful taken loans
    uint successfulGLoansCount; //successful guaranteed loans
}

function validate(uint loanID) {

}


struct Group {
    uint totalLoanAmount;
    uint membersCount;
    bool isPaying;
    Borrower[] members;
}

struct Loan {
    uint loanID;
    User borrower;
    uint amountTotal;
    uint dueDate;
    Group group;
    bool paymentMethod; //true = once a month, false = in the end of duedate
    uint amountOutstanding;
}










//******  GENERAL FUNCTIONS     *************
function totalSumOfTLoans(User borrower) external view returns (uint256) {
        uint sum = 0;
       for (uint i=0; i<borrower.loans.length; i++){
        sum += borrower.loans[i];
       }
       return sum;
}
function computeHistoryImpact(User user) {
    
}
function updateCreditScore(User user, int256 plusPoints) external view returns (int256) {
    return  user.creditScore += plusPoints;
}

function checkCreditEligibility(User user, int256 requiredScore) external view returns (bool) {
    return user.
    creditScore >= requiredScore;
}


function loanTransfer(Loan loan, Group group) {
    for (uint i = 0; i < loan.group.members.length; i++) {
        loan.group.members[i].applyForLoan(loan.amount, loan.dueDate, groupID, paymentMethod);
    }
}

function endLoan(Loan loan, bool repaid) {
    if (repaid) {
        updateCreditScore(loan.borrower, 10);
        loan.borrower.successfulTLoansCount++;
        for (uint i = 0; i < loan.group.members.length; i++) {
            updateCreditScore(loan.group.members[i], 2);
            loan.group.members[i].successfulGLoansCount++;
        }
    } else {
        updateCreditScore(loan.borrower, -40);
        for (uint i = 0; i < loan.group.members.length; i++) {
            updateCreditScore(loan.group.members[i], -10);
        }
    }
}

struct LiquidityProbider {
    address payable providerAddress;
}
//******  LOAN FUNCTIONS     *************
function isRepaid() {
   this;
}

//******  USER FUNCTIONS     *************
function applyForLoan(uint amount, uint dueDate, uint groupID, bool paymentMethod) external view returns (bool){
    require(moleculeGeneralSanctionController.check(regionalIds, msg.sender), "Address is sanctioned.");
    require(checkCreditEligibility(this, -70), "Credit score is too low.");

}

function payForLoan(uint payment) public payable {
    // check the balance of the address
    // address(this)

    require(condition);
    msg.
    this.address.
    amountOutstanding -= payment;
}
//******  GROUP FUNCTIONS     *************
}