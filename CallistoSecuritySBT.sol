// SPDX-License-Identifier: No License (None)
pragma solidity 0.8.18;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

}

contract CallistoSecuritySBT is Ownable {

    string public constant name = "Callisto Security SBT";
    string public constant symbol = "AuditsSBT";
    string private baseURI;
    uint256 public totalSupply;


    struct Report {
        address auditedContract;
        uint8 lowSeverityIssues;
        uint8 mediumSeverityIssues;
        uint8 highSeverityIssues;
        uint8 ownersPrivileges;
        uint8 rank; // overall security rank
        string auditor; // auditor of contract (company, site URL)
        string reportURL;   // report URL (IPFS or auditors website)
        string developerNotes;  // developer can add arbitrary notes
    }

    mapping(address _contract => address _developer) public contractDeveloper;  //  developer (owner) of audited contract
    mapping(uint256 _tokenId => address _contract) public ownerOf;
    mapping(uint256 _tokenId => Report) public reports;
    mapping(address _manager => bool _active) public managers;
    mapping(address _contract => uint256[] _tokenId) public tokensOfOwner;
    mapping(address _contract => mapping(uint256 _tokenId => uint256 _index)) private _ownedTokens;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event SetManager(address manager, bool isActive);

    modifier onlyManagerOrOwner() {
        require(managers[msg.sender] || owner() == msg.sender, "onlyManagerOrOwner");
        _;
    }

    modifier onlyDeveloper(address _contract) {
        require(contractDeveloper[_contract] == msg.sender, "Only developer");
        _;
    }

    constructor (string memory _baseURI) {
        baseURI = _baseURI;
    }

    // returns number of reports
    function balanceOf(address _contract) public view returns(uint256) {
        return tokensOfOwner[_contract].length;
    }

    // returns URI to metadata. For example, "https://audits.callisto.network/820/"
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return string.concat(baseURI, uint256ToString(_tokenId));
    }

    function getReports(address _auditedContract) external view returns(Report[] memory) {
        uint256 numberOfReports = tokensOfOwner[_auditedContract].length;
        Report[] memory r = new Report[](numberOfReports);
        for (uint i=0; i < numberOfReports; i++) {
            r[i] = reports[tokensOfOwner[_auditedContract][i]];
        }
        return r;
    }

    // set referral address for user "to", if it was not set before 
    function addReport(address _to, Report calldata _report) external onlyManagerOrOwner {
        uint256 tokenId = totalSupply;
        totalSupply = tokenId + 1; // increment of totalSupply 
        ownerOf[tokenId] = _to;
        uint256 index = tokensOfOwner[_to].length;
        tokensOfOwner[_to].push(tokenId);
        _ownedTokens[_to][tokenId] = index;
        reports[tokenId] = _report;
        emit Transfer(address(0), _to, tokenId);
    }

    // delete token (report)
    function deleteReport(address _auditedContract, uint256 _tokenId) external onlyManagerOrOwner {
        require(_auditedContract == reports[_tokenId].auditedContract, "Wrong address");
        uint256 index = _ownedTokens[_auditedContract][_tokenId];
        uint256 lastIndex = tokensOfOwner[_auditedContract].length - 1;
        if (index != lastIndex) {
            uint256 lastToken = tokensOfOwner[_auditedContract][lastIndex];
            tokensOfOwner[_auditedContract][index] = lastToken;
            _ownedTokens[_auditedContract][lastToken] = index;
        }
        tokensOfOwner[_auditedContract].pop();
        delete _ownedTokens[_auditedContract][_tokenId];
        delete reports[_tokenId];
        emit Transfer(_auditedContract, address(0), _tokenId);
    }

    // update report
    function updateReport(address _auditedContract, uint256 _tokenId, Report calldata _report) external onlyManagerOrOwner {
        require(_auditedContract == reports[_tokenId].auditedContract, "Wrong address");
        reports[_tokenId] = _report;
    }

    // Developer can add own notes to contract report
    function updateDeveloperNotes(address _auditedContract, uint256 _tokenId, string calldata _notes) external onlyDeveloper(_auditedContract) {
        require(_auditedContract == reports[_tokenId].auditedContract, "Wrong address");
        reports[_tokenId].developerNotes = _notes;
    }

    // set developer of audited contract. Developer can add own notes to contract report
    function setDeveloper(address _contract, address _developer) external onlyManagerOrOwner {
        require(balanceOf(_contract) != 0, "No reports");
        require(_developer != address(0));
        contractDeveloper[_contract] = _developer;
    }

    // set baseURI
    function setBaseURI(string calldata _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    // set manager address 
    function setManager(address _manager, bool _isActive) external onlyOwner {
        require(_manager != address(0));
        managers[_manager] = _isActive;
        emit SetManager(_manager, _isActive);
    }

    function uint256ToString(uint256 number) internal pure returns (string memory) {
        if (number == 0) { return "0"; }
        uint256 length;
        uint256 temp = number;
        while (temp != 0) {
            length++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(length);
        while (number != 0) {
            length -= 1;
            buffer[length] = bytes1(uint8(48 + (number % 10)));
            number /= 10;
        }
       return string(buffer);
    }
}