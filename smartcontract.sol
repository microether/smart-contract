// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LiquidityPool.sol";
import "https://github.com/molecule-protocol/molecule-core/blob/main/src/v2/interfaces/IMoleculeController.sol";
import "./MyCustomController.sol";

contract MicroEther {
    MyCustomController public myCustomController; //can be used for additional conditions to control the transactions
    // in order to prevent them
    IMoleculeController public moleculeGeneralSanctionController;
    uint[] public regionalIds;
    constructor(MyCustomController _myCustomController, IMoleculeController _moleculeGeneralSanctionController) {
        myCustomController = _myCustomController; //can be used for additional conditions to control the transactions
    // in order to prevent them
        moleculeGeneralSanctionController = _moleculeGeneralSanctionController;
    }
    function addRegionalId(uint _regionalId) external {
        regionalIds.push(_regionalId);
    }
    /*function myFunction() external {
        require(moleculeGeneralSanctionController.check(regionalIds, msg.sender), "Address is sanctioned.");
        require(myCustomController.check(msg.sender), "Address is not authorized.");
        // Access allowed to function code here
    }*/

    LiquidityPool private liquidityPool;

    address constant LIQUIDITY_POOL_ADDRESS = 0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47;

    enum RepaymentMethod { Monthly, Quarterly, Yearly }
    enum LoanType { Uncollateralized, SocialCollateral }

    struct Loan {
        address payable borrower; // added borrower field
        uint256 amount;
        uint256 dueDate;
        uint256 interestRate; // added interestRate field
        RepaymentMethod repaymentMethod;
        LoanType loanType;
        int8 numGuarantors;
        int8 actualGuarantors;
        bool isFunded;
    }

    uint256 private loanIDCounter = 0;
    mapping(address => int) public creditScores; // Changed to int
    mapping(uint256 => Loan) public loans;
    mapping(uint256 => address[]) public loanGuarantors;

    uint256 constant MIN_GUARANTORS = 10;
    int constant UNC_COLLATERAL_THRESHOLD = 50;
    int constant SCORE_DECREASE_BORROWER = 40;
    int constant SCORE_INCREASE_BORROWER = 10;
    int constant SCORE_DECREASE_GUARANTOR = 10;
    int constant SCORE_INCREASE_GUARANTOR = 2;
    int constant MINIMUM_SCORE = -70;
    int constant MAX_SCORE = 100;

    event LoanApplied(uint256 loanId, address indexed borrower);
    event LoanGuaranteed(uint256 loanId, address indexed guarantor);
    event LoanFunded(uint256 loanId);



    constructor() {
        liquidityPool = LiquidityPool(LIQUIDITY_POOL_ADDRESS);
        // Rest of the constructor
        creditScores[msg.sender] = 0;
    }

    function calculateInterestRate(address borrower, LoanType collateral) private view returns (uint256) {
    int score = creditScores[borrower];
    uint256 Rmin;
    uint256 Rmax;

    if(collateral == LoanType.SocialCollateral) {
        Rmin = 2;
        Rmax = 6;
    } else {
        Rmin = 10;
        Rmax = 15;
    }
    
    uint256 R = Rmin + ((Rmax - Rmin) * (100 - uint256(score))) / 200;
    return R;
}

    function applyForLoan(
        uint256 _loanAmount,
        uint256 _dueDate,
        RepaymentMethod _repaymentMethod,
        LoanType _loanType,
        int8 _numGuarantors
    ) public returns (uint256) {
        require(moleculeGeneralSanctionController.check(regionalIds, msg.sender), "Address is sanctioned."); 
        require(creditScores[msg.sender] >= MINIMUM_SCORE, "Credit score too low");
        require(_numGuarantors >= 5 && _numGuarantors <= 20, "Invalid number of guarantors");
        
        uint256 interestRate = calculateInterestRate(msg.sender, _loanType);
        
        if(_loanType == LoanType.Uncollateralized) {
            require(creditScores[msg.sender] > UNC_COLLATERAL_THRESHOLD, "Credit score not sufficient for uncollateralized loan");
        } else if(_loanType == LoanType.SocialCollateral) {
            creditScores[msg.sender] += _numGuarantors;
            if (creditScores[msg.sender] > MAX_SCORE) {
                creditScores[msg.sender] = MAX_SCORE;
            }
        }

        loanIDCounter++;
        loans[loanIDCounter] = Loan({
            borrower: payable(msg.sender), // set borrower field
            amount: _loanAmount,
            dueDate: _dueDate,
            interestRate: interestRate, // set interestRate field
            repaymentMethod: _repaymentMethod,
            loanType: _loanType,
            numGuarantors: _numGuarantors,
            actualGuarantors: 0,
            isFunded: false
        });
        
        emit LoanApplied(loanIDCounter, msg.sender);

        return loanIDCounter;
    }

 // In the future, Guarantors have to be verified by World ID
 // To guarantee that they are all individual people

    function guaranteeLoan(uint256 _loanId) external {
        Loan storage loan = loans[_loanId];
        require(loan.loanType == LoanType.SocialCollateral, "Only social collateral loans can be guaranteed");
        require((int256)(loanGuarantors[_loanId].length) < loan.numGuarantors, "This loan already has enough guarantors");

        loanGuarantors[_loanId].push(msg.sender);
        emit LoanGuaranteed(_loanId, msg.sender);

        if ((int256)(loanGuarantors[_loanId].length) == loan.numGuarantors) {
            loan.isFunded = true;
            // Implement the funding logic here. You will need a pool of funds to draw from.
            emit LoanFunded(_loanId);
        }
    }

    function repayLoan(uint256 _loanId) external payable {
        Loan storage loan = loans[_loanId];
        require(msg.sender == loan.borrower, "Only the borrower can repay");
        uint256 expectedRepayment = loans[_loanId].amount + (loans[_loanId].amount * calculateInterestRate(loans[_loanId].borrower, loans[_loanId].loanType) / 100);
        require(msg.value == expectedRepayment, "Incorrect repayment amount");

        if (block.timestamp <= loan.dueDate) {
            creditScores[loan.borrower] += SCORE_INCREASE_BORROWER;
            for (uint256 i = 0; i < loanGuarantors[_loanId].length; i++) {
                creditScores[loanGuarantors[_loanId][i]] += SCORE_INCREASE_GUARANTOR;
            }
        } else {
            creditScores[loan.borrower] -= SCORE_DECREASE_BORROWER;
            for (uint256 i = 0; i < loanGuarantors[_loanId].length; i++) {
                creditScores[loanGuarantors[_loanId][i]] -= SCORE_DECREASE_GUARANTOR;
            }
        }

        // Transfer the ether to a safe storage or use it to fund other loans.
        // For this example, let's assume there's an owner/admin that collects repayments.
        // The "owner" could be a multi-signature wallet, another smart contract, or a centralized entity.
        address payable owner = payable(address(this));  // Replace with the desired address
        owner.transfer(msg.value);
        
        // Repay the liquidity pool
        liquidityPool.deposit(msg.value);
    }

    function vouchForLoan(uint256 _loanID) public {
        Loan storage loan = loans[_loanID];
        require(loan.loanType == LoanType.SocialCollateral, "Can only vouch for social collateral loans");
        require(loan.actualGuarantors < loan.numGuarantors, "Already has enough guarantors");

        loanGuarantors[_loanID].push(msg.sender);
        loan.actualGuarantors++;

        if (loan.actualGuarantors == loan.numGuarantors) {
            // If the desired number of guarantors is reached, you can implement further logic.
            // For example, you might notify the borrower that their loan is now fully vouched for.
            emit LoanFunded(_loanID);
        }
    }

    // Modified function when loan is funded
    function fundLoan(uint256 _loanId) internal {
        Loan storage loan = loans[_loanId];
        require(loan.isFunded == false, "Loan already funded");
        uint256 interest = calculateInterestRate(msg.sender, loan.loanType);
        uint256 totalAmount = loan.amount + (loan.amount * interest / 100);

        // Withdraw funds from the liquidity pool
        liquidityPool.withdraw(totalAmount);

        loan.isFunded = true;
        payable(msg.sender).transfer(totalAmount);  // sending funds to the borrower
        emit LoanFunded(_loanId);
    }

    function addFunds() external payable {}

    receive() external payable {}
}

