pragma solidity ^0.8.0;
import "https://github.com/molecule-protocol/molecule-core/blob/main/src/v2/interfaces/IMoleculeController.sol";
import "./MyCustomController.sol";
contract MyContract {
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