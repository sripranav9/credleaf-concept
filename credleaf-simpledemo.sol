// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Credleaf {
    address public admin;
    uint256 public nextCreditId;

    struct CarbonCredit {
        string projectName; // e.g., Amazon
        uint256 amount; // e.g., 5 tons CO₂
        string evidence; // e.g., IPFS link or invoice
        address sourceVendor; // original project developer
        bool retired;
    }

    mapping(uint256 => CarbonCredit) public credits;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256[]) public creditsOf;

    event CreditMinted(address indexed to, uint256 indexed creditId, uint256 amount, address indexed source);
    event CreditRetired(uint256 indexed creditId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    modifier onlyOwner(uint256 creditId) {
        require(msg.sender == ownerOf[creditId], "Not the credit owner");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Admin mints a credit on behalf of a verified project (sourceVendor)
    function mintCredit(
        address _to,
        string memory _projectName,
        uint256 _amount,
        string memory _evidence,
        address _sourceVendor
    ) public onlyAdmin {
        CarbonCredit memory newCredit = CarbonCredit({
            projectName: _projectName,
            amount: _amount,
            evidence: _evidence,
            sourceVendor: _sourceVendor,
            retired: false
        });

        credits[nextCreditId] = newCredit;
        ownerOf[nextCreditId] = _to;
        creditsOf[_to].push(nextCreditId);

        emit CreditMinted(_to, nextCreditId, _amount, _sourceVendor);

        nextCreditId++;
    }

    // Owner retires the credit, marking it as used for ESG
    function retireCredit(uint256 _creditId) public onlyOwner(_creditId) {
        require(!credits[_creditId].retired, "Already retired");
        credits[_creditId].retired = true;

        emit CreditRetired(_creditId);
    }

    // View function to get all credit IDs for a company
    function getCreditsOf(address _company) public view returns (uint256[] memory) {
        return creditsOf[_company];
    }

    // View detailed info of a specific credit
    function getCredit(uint256 _creditId)
        public
        view
        returns (
            string memory projectName,
            uint256 amount,
            string memory evidence,
            address sourceVendor,
            bool retired
        )
    {
        CarbonCredit memory c = credits[_creditId];
        return (c.projectName, c.amount, c.evidence, c.sourceVendor, c.retired);
    }
}
