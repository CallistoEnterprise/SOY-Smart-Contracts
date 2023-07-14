// SPDX-License-Identifier: No License (None)
pragma solidity 0.8.18;

interface IERC223 {
    function balanceOf(address who) public virtual view returns (uint);
    function transfer(address to, uint value) public virtual returns (bool success);
    /**
     * @dev Transfers `value` tokens from `msg.sender` to `to` address with `data` parameter
     * and returns `true` on success.
     */
    function transfer(address to, uint value, bytes memory data) public virtual returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    /* will use initialize instead
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    */
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

contract ReferralTracker is Ownable {

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address public constant SOY_ADDRESS = 0x9FaE2529863bD691B4A7171bDfCf33C7ebB10a65;
    string public constant name = "Soy Referrals SBT";
    string public constant symbol = "RefSBT";
    uint256 public total;
    uint256 public totalReferralFee;
    address public system;
    mapping(uint256 _tokenId => address) public ownerOf;
    mapping(address _owner => uint256) public balanceOf;
    mapping(address => address) public referrals;   // user => referral  

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    modifier onlySystem() {
        require(system == msg.sender, "Only system");
        _;
    }

    function initialize(address newOwner, address newSystem) external {
        require(_owner == address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        totalReferralFee = 500; // 5%
        IERC223(SOY_ADDRESS).approve(address(this), type(uint256).max);
    }


    // set referral address for user "to", if it was not set before 
    function mint(address to, address from_ref) external onlySystem {
        if(referrals[to] == address(0)) {
            uint256 tokenId = total++;
            ownerOf[tokenId] = to;
            balanceOf[to] = 1;
            referrals[to] = from_ref;
            emit Transfer(address(0), to, tokenId);
        }
    }

    // returns fee percentage with 2 decimals for particular user 
    function userFee(address user) external view returns(uint256) {
        return totalReferralFee;
    }

    function tokenReceived(address _from, uint256 _amount, bytes memory _data) {
        require(msg.sender == SOY_ADDRESS, "Wrong token");
        require(_data.length == 32, "wrong parameter");
        address user = abi.decode(_data, (address));
        require(user != address(0), "wrong address");
        _processRef(user, _amount);
    }

    function _processRef(address user, uint256 amount) internal {
        address ref = referrals[user];
        if(ref == address(0)) ref = BURN_ADDRESS;   // if no referral then burn 
        IERC223(SOY_ADDRESS).transferFrom(address(this), ref, amount);  // use transferFrom to avoid revert by evil user
    }

    // set referral fee in percentage with 2 decimals (i.e. 500 = 5%)
    function setReferralFee(uint256 fee) external onlyOwner {
        require(fee < 5000);
        totalReferralFee = fee;
    }

    // set system address
    function setSystem(uint256 _system) external onlyOwner {
        require(_system != address(0));
        system = _system;
    }
}