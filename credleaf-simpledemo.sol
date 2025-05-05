// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EcoProof {
    address public admin;

    struct CarbonCredit {
        string projectName;
        uint256 amount;
        string evidence;
        bool retired;
    }

    mapping(uint256 => CarbonCredit) public credits;
    mapping(address => uint256[]) public creditsOf;
    uint256 public nextCreditId;

    constructor() {
        admin = msg.sender;
    }

    function mintCredit(
        address _company,
        string memory _projectName,
        uint256 _amount,
        string memory _evidence
    ) public {
        require(msg.sender == admin, "Only admin can mint");

        credits[nextCreditId] = CarbonCredit(
            _projectName,
            _amount,
            _evidence,
            false
        );
        creditsOf[_company].push(nextCreditId);
        nextCreditId++;
    }

    function retireCredit(uint256 _creditId) public {
        require(!credits[_creditId].retired, "Already retired");
        credits[_creditId].retired = true;
    }

    function getCredit(uint256 _creditId)
        public
        view
        returns (
            string memory,
            uint256,
            string memory,
            bool
        )
    {
        CarbonCredit memory c = credits[_creditId];
        return (c.projectName, c.amount, c.evidence, c.retired);
    }

    function getCreditsOf(address _company)
        public
        view
        returns (uint256[] memory)
    {
        return creditsOf[_company];
    }
}
