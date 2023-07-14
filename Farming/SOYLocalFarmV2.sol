// SPDX-License-Identifier: No License (None)
pragma solidity 0.8.18;


interface IERC223 {
    function balanceOf(address who) external view returns (uint);
    function transfer(address to, uint value) external;
    function transfer(address to, uint value, bytes memory data) external returns (bool success);
}

abstract contract IERC223Recipient {
    
 struct ERC223TransferInfo
    {
        address token_contract;
        address sender;
        uint256 value;
        bytes   data;
    }
    ERC223TransferInfo private tkn;
    
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenReceived(address _from, uint _value, bytes calldata _data) public virtual;
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

abstract contract RewardsRecipient {
    address public globalFarm;

    function notifyRewardAmount(uint256 reward) external virtual;

    modifier onlyGlobalFarm() {
        require(msg.sender == globalFarm, "Caller is not global Farm contract");
        _;
    }
}


interface ISimplifiedGlobalFarm {
    function mintFarmingReward(address _localFarm) external;
    function getAllocationX1000(address _farm) external view returns (uint256);
    function getRewardPerSecond() external view returns (uint256);
    function rewardMintingAvailable(address _farm) external view returns (bool);
    function farmExists(address _farmAddress) external view returns (bool);
    function owner() external view returns (address);
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */
library EnumerableSet {

    struct AddressSet {
        // Storage of set values
        address[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (address => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            address lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns 1-based index of value in the set. O(1).
     */
    function indexOf(AddressSet storage set, address value) internal view returns (uint256) {
        return set._indexes[value];
    }


    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
}

interface ICallistoNFT {
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transfer(address _to, uint256 _tokenId, bytes calldata _data) external returns (bool);
    function silentTransfer(address _to, uint256 _tokenId) external returns (bool);
}

interface IReferralTracker {
    function userFee(address user) external view returns(uint256);   // fee percentage with 2 decimals for particular user 
}

interface ISoyFinancePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


contract SOYLocalFarmV2 is IERC223Recipient, ReentrancyGuard, RewardsRecipient
{
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet boostNFTs; // NFT contracts provided bonuses
    IReferralTracker public referralTrackingContract;    // contract to track referrals and pay fee
    uint256 constant MAX_AMOUNT = 1e40; // Prevents accumulatedRewardPerShare from overflowing.
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    // SoyFinance factory contract = 0x9CC7C769eA3B37F1Af0Ad642A268b80dc80754c5 defined in the function pairFor()
    uint256 public insuranceFee;   // fee percentage with 2 decimals will be transferred to insurance fund
    uint256 public burnFee;    // fee percentage with 2 decimals will be burned
    uint256 public totalShares; // effective total shares included bonuses
    address public insuranceAddress;
    IERC223 public rewardsToken;
    address public lpToken;
    uint256 public lastRewardTimestamp;  // Last block number that SOY distribution occurs.
    uint256 public accumulatedRewardPerShare; // Accumulated SOY per share, times 1e18.
    bool public active;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardPerSharePaid; // Accumulated SOY per share that was paid
        uint256 bonus;   // percent of bonus applied
        address nft;     // deposited NFT
        uint256 tokenId; // NFT tokenID
    }
    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) public userInfo;
    mapping(address NFT => uint256 boost) public boostPercentage;  // NFT contract address => boost %
    mapping(address pair => address token) public allowedTokensReceive; // allow to receive tokens from swapping pool
    
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardReinvested(address indexed user, uint256 reward);
    event SetInsuranceWallet(address wallet);
    event SetReferralTracking(address refTrack);
    
    

    /* ========== CONSTRUCTOR ========== */

    constructor(
        bool _active,
        address _lpToken // LP token that will be staked in this Local Farm
    )
    {
        active = _active;
        lpToken = _lpToken;
        //test net
        //rewardsToken = IERC223(0x4c20231BCc5dB8D805DB9197C84c8BA8287CbA92);  // Soy token
        //globalFarm = 0x9F66541abc036503Ae074E1E28638b0Cb6165458;
        //insuranceAddress = 0x27d1a09fca4196ef8513aF068277AE96da083F49; // insurance wallet
        //referralTrackingContract = IReferralTracker(0xA3141cB11cfCd7dFEE9211b49627b4FdEa521fc4);
        // main net
        rewardsToken = IERC223(0x9FaE2529863bD691B4A7171bDfCf33C7ebB10a65);  // Soy token
        globalFarm = 0x64Fa36ACD0d13472FD786B03afC9C52aD5FCf023;
        insuranceAddress = 0x27d1a09fca4196ef8513aF068277AE96da083F49; // insurance wallet
        referralTrackingContract = IReferralTracker(0x0A17432e963AD18C280fb4bc6C00c4Ad186051C0);
        insuranceFee = 200; // 2%
        address token0 = ISoyFinancePair(_lpToken).token0();
        address token1 = ISoyFinancePair(_lpToken).token1();
        if (token0 != address(rewardsToken) && token1 != address(rewardsToken)) {
            address pair = pairFor(token0, address(rewardsToken));
            allowedTokensReceive[pair] = token0;
            pair = pairFor(token1, address(rewardsToken));
            allowedTokensReceive[pair] = token1;
        }
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "only owner");
        _;
    }
    
    modifier onlyActive {
        require(active, "The farm is not enabled by owner!");
        _;
    }
    
    function setActive(bool _status) external onlyOwner
    {
        active = _status;
    }
    
    function owner() public view returns(address) {
        return ISimplifiedGlobalFarm(globalFarm).owner();
    }

    /* ========== ERC223 transaction handlers ====== */
    
    // Analogue of deposit() function.
    function tokenReceived(address _from, uint256 _amount, bytes calldata ) public override nonReentrant onlyActive
    {
        if (_from == lpToken || allowedTokensReceive[_from] == msg.sender) return; // allow to receive tokens form pair contract for reinvestment

        require(msg.sender == address(lpToken), "Trying to deposit wrong token");
        uint256 userAmount = userInfo[_from].amount;
        require(userAmount + _amount <= MAX_AMOUNT, 'exceed the top');
        update();
        _payRewards(_from);

        if (_amount > 0) {
            uint256 shares = userAmount * (100 + userInfo[_from].bonus) / 100;
            uint256 newShares = (userAmount + _amount) * (100 + userInfo[_from].bonus) / 100;
            totalShares = totalShares + newShares - shares;
            userInfo[_from].amount += _amount;
        }
        
        emit Staked(_from, _amount);
    }
    
    
    function notifyRewardAmount(uint256 reward) external override
    {
        emit RewardAdded(reward);
    }
    
    function getRewardPerSecond() public view returns (uint256)
    {
        return ISimplifiedGlobalFarm(globalFarm).getRewardPerSecond();
    }
    
    function getAllocationX1000() public view returns (uint256)
    {
        return ISimplifiedGlobalFarm(globalFarm).getAllocationX1000(address(this));
    }
    
    /* ========== Farm Functions ====== */

    // View function to see pending Reward on frontend.
    function pendingReward(address _user) external view returns (uint256 pending) {
        UserInfo storage user = userInfo[_user];
        uint256 _accumulatedRewardPerShare = accumulatedRewardPerShare;
        if (block.timestamp > lastRewardTimestamp && totalShares != 0) {
            uint256 multiplier = block.timestamp - lastRewardTimestamp;
            uint256 _reward = multiplier * getRewardPerSecond() * getAllocationX1000() / 1000;
            _accumulatedRewardPerShare = accumulatedRewardPerShare + (_reward * 1e18 / totalShares);
        }
        uint256 shares = user.amount * (100 + user.bonus) / 100;
        pending = shares * (_accumulatedRewardPerShare - user.rewardPerSharePaid) / 1e18;

        // calculate fees
        uint256 refFee;
        if (address(referralTrackingContract) != address(0)) {
            refFee = referralTrackingContract.userFee(_user); // refFee is percentage with 2 decimals
            refFee = pending * refFee / 10000;  // refFee - amount of fee
        }
        uint256 bFee = pending * burnFee / 10000;  // burn fee amount
        uint256 iFee = pending * insuranceFee / 10000;  // insurance fee amount
        pending = pending - (refFee + iFee + bFee);
    }
    
    

    // Update reward variables of this Local Farm to be up-to-date.
    function update() public {
        ISimplifiedGlobalFarm(globalFarm).mintFarmingReward(address(this));
        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }
       
        if (totalShares == 0) {
            lastRewardTimestamp = block.timestamp;
            return;
        }
        uint256 multiplier = block.timestamp - lastRewardTimestamp;
        
        // This silently calculates "assumed" reward!
        // This function does not take contract's actual balance into account
        // Global Farm and `reward_request` modifier are responsible for keeping this contract
        // stocked with funds to pay actual rewards.
        
        uint256 _reward = multiplier * getRewardPerSecond() * getAllocationX1000() / 1000;
        accumulatedRewardPerShare = accumulatedRewardPerShare + (_reward * 1e18 / totalShares);
        lastRewardTimestamp = block.timestamp;
    }
    

    // Withdraw tokens from STAKING.
    function withdraw(uint256 _amount) public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        
        update();
        _payRewards(msg.sender);
        if(_amount > 0) {
            uint256 shares = user.amount * (100 + user.bonus) / 100;
            user.amount = user.amount - _amount;
            uint256 newShares = user.amount * (100 + user.bonus) / 100;
            totalShares = totalShares + newShares - shares; // update total shares
            IERC223(lpToken).transfer(msg.sender, _amount);
        }

        emit Withdraw(msg.sender, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        IERC223(lpToken).transfer(msg.sender, user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
        uint256 shares = user.amount * (100 + user.bonus) / 100;
        if (totalShares >= shares) totalShares -= shares;
        else totalShares = 0;
        user.amount = 0;
        user.rewardPerSharePaid = 0;
    }
    
    // Special function that allows owner to withdraw remaining unclaimed tokens of inactive farms
    function withdrawInactiveReward() public onlyOwner
    {
        require(!ISimplifiedGlobalFarm(globalFarm).farmExists(address(this)), "Farm must not be active");
        
        rewardsToken.transfer(msg.sender, rewardsToken.balanceOf(address(this)));
    }
    
    function rescueERC20(address token, address to) external onlyOwner {
        require(token != address(rewardsToken), "Reward token is not prone to ERC20 issues");
        require(token != address(lpToken), "LP token is not prone to ERC20 issues");
        
        
        uint256 value = IERC223(token).balanceOf(address(this));
        IERC223(token).transfer(to, value);
    }


    // on received boost NFT
    function onERC721Received(address, address _from, uint256 _tokenId, bytes calldata) external nonReentrant returns(bytes4) {
        require(boostNFTs.contains(msg.sender), "Not a boost NFT");
        UserInfo storage user = userInfo[_from];
        require(user.nft == address(0), "NFT already added");
        update();
        _payRewards(_from);
        user.nft = msg.sender;
        user.bonus = boostPercentage[msg.sender];
        user.tokenId = _tokenId;
        uint256 shares = user.amount * (100 + user.bonus) / 100;
        totalShares = totalShares + shares - user.amount; // update total shares
        return this.onERC721Received.selector;
    }

    // withdraw boost NFT
    function withdrawNFT() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        address nft = user.nft;
        require(nft != address(0), "No NFT");
        user.nft = address(0);
        update();
        _payRewards(msg.sender);
        // reduce shares by bonus
        uint256 shares = user.amount * (100 + user.bonus) / 100;
        totalShares = totalShares + user.amount - shares; // update total shares
        user.bonus = 0;

        ICallistoNFT(nft).silentTransfer(msg.sender, user.tokenId);
    }

    function _payRewards(address _user) internal {
        uint256 pending = _calculateReward(_user);
        if(pending > 0) rewardsToken.transfer(_user, pending);
        emit RewardPaid(_user, pending);
    }

    // calculate pending reward and pay fees
    function _calculateReward(address _user) internal returns(uint256 pending) {
        UserInfo storage user = userInfo[_user];
        uint256 shares = user.amount * (100 + user.bonus) / 100;
        pending = shares * (accumulatedRewardPerShare - user.rewardPerSharePaid) / 1e18;
        if(pending > 0) {
            uint256 refFee;
            if (address(referralTrackingContract) != address(0)) 
                refFee = referralTrackingContract.userFee(_user); // refFee is percentage with 2 decimals
            if (refFee != 0) {
                refFee = pending * refFee / 10000;  // refFee - amount of fee
                bytes memory data = abi.encode(_user);
                rewardsToken.transfer(address(referralTrackingContract), refFee, data);
            }
            uint256 bFee = pending * burnFee / 10000;  // burn fee amount
            if (bFee != 0) rewardsToken.transfer(BURN_ADDRESS, bFee);
            uint256 iFee = pending * insuranceFee / 10000;  // insurance fee amount
            if (iFee != 0) rewardsToken.transfer(insuranceAddress, iFee);
            pending = pending - (refFee + iFee + bFee);
        }
        user.rewardPerSharePaid = accumulatedRewardPerShare;
    }
    
    function setInsuranceWallet(address wallet) external onlyOwner {
        require(wallet != address(0));
        insuranceAddress = wallet;
        emit SetInsuranceWallet(wallet);
    }

    function setReferralTracking(address refTrack) external onlyOwner {
        require(refTrack != address(0));
        referralTrackingContract = IReferralTracker(refTrack);
        emit SetReferralTracking(refTrack);
    }

    // set fees percentage with 2 decimals (i.e. 100 = 1%)  
    function setFees(uint256 _burnFee, uint256 _insuranceFee) external onlyOwner {
        require(_burnFee < 10000 && _insuranceFee < 10000);
        burnFee = _burnFee;
        insuranceFee = _insuranceFee;
    }

    // set boost NFT contract and boost percentage (without decimals). If boost = 0, it will remove NFT contract
    function setBoostNFT(address[] memory contractNFT, uint256[] memory boost) external onlyOwner {
        require(contractNFT.length == boost.length, "wrong length");
        for (uint i=0; i<boost.length; i++) {
            require(contractNFT[i] != address(0), "Zero address");
            if (boost[i] == 0) {
                boostNFTs.remove(contractNFT[i]);
                boostPercentage[contractNFT[i]] = 0;
            } else {
                boostNFTs.add(contractNFT[i]);
                boostPercentage[contractNFT[i]] = boost[i];
            }
        }
    }

    function setGlobalFarm(address _globalFarm) external onlyOwner {
        require(_globalFarm != address(0));
        require(ISimplifiedGlobalFarm(_globalFarm).owner() == msg.sender, "New contract has another owner");
        globalFarm = _globalFarm;
    }

    // returns list of boost NFTs and its boost percentage
    function getBoostNFT() external view returns(address[] memory NFTs, uint256[] memory boosts) {
        uint len = boostNFTs.length();
        NFTs = new address[](len);
        boosts = new uint256[](len);
        for (uint i=0; i<len; i++) {
            NFTs[i] = boostNFTs.at(i);
            boosts[i] = boostPercentage[NFTs[i]];
        }
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    // calculate amounts base on available amount of tokenIn
    function calcAmountIn(uint256 availableAmount, uint256 reserveIn) internal pure returns (uint256 amountIn) {
        uint256 d = (1998*1998)*reserveIn*reserveIn + (4000*998)*reserveIn*availableAmount;
        amountIn = (sqrt(d) - 1998*reserveIn) / (2 * 998);
    }

    // calculate amounts In and Out for pairs A and B
    function calcAmounts(uint256 availableAmount, uint256 aI, uint256 aO, uint256 bI, uint256 bO, uint256 pA, uint256 pB) internal pure returns(uint256,uint256,uint256,uint256) {
        uint256 bO1 = bO*pA/pB;
        uint256 c = 998*availableAmount/1000;
        pA = aI + bI + c; // A
        pB = aO*(bI + c) + bO1*(aI + c); // -B
        //bI = aO*bO; // *c // C
        pB = pB /(2*pA);    // -P/2
        c = (aO*bO1) / pA * c;    // Q
        c = pB - sqrt(pB*pB - c); // amount out = -P/2 - Sqrt((P/2)^2 - Q)
       
        // get amounts
        aI = getAmountIn(c,aI,aO);  // amountIn for pair A
        aO = c;    // amountOut for pair A
        c = availableAmount - aI;
        bO = getAmountOut(c,bI,bO);    // amountOut for pair B
        bI = c;    // amountIn for pair B
        return(aI,aO,bI,bO);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns(uint256 amountOut) {
        uint256 amountInWithFee = amountIn * 998;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, "INSUFFICIENT_OUTPUT_AMOUNT");
        uint numerator = reserveIn*amountOut*1000;
        uint denominator = (reserveOut-amountOut)*998;
        amountIn = (numerator / denominator)+1;
    }

    function getReserves(address tokenIn, address tokenOut) internal view returns(uint256 reserveIn, uint256 reserveOut, address pair) {
        pair = pairFor(tokenIn, tokenOut);
        (reserveIn, reserveOut,) = ISoyFinancePair(pair).getReserves();
        require(reserveIn > 0 && reserveOut > 0, "reinvestPools: pair error");
        if (tokenOut < tokenIn) 
            (reserveIn, reserveOut) = (reserveOut, reserveIn);
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address tokenA, address tokenB) internal pure returns (address pair) {
        address factory = 0x9CC7C769eA3B37F1Af0Ad642A268b80dc80754c5;
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint256(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'e410ea0a25ce340e309f2f0fe9d58d787bb87dd63d02333e8a9a747230f61758' // init code hash
            )))));
    }

    function reinvest() external returns(uint256 rewardReinvested) {
        update();
        uint256 liquidity;
        rewardReinvested = _calculateReward(msg.sender);
        if(rewardReinvested > 0) {
            address token0 = ISoyFinancePair(lpToken).token0();
            address token1 = ISoyFinancePair(lpToken).token1();
            if (token0 == address(rewardsToken)) {
                liquidity = reinvestSoyPool(rewardReinvested, token1);
            } else if (token1 == address(rewardsToken)) {
                liquidity = reinvestSoyPool(rewardReinvested, token0);
            } else {
                liquidity = reinvestPools(rewardReinvested, token0, token1);
            }
            emit RewardReinvested(msg.sender, rewardReinvested);
        }
        if (liquidity > 0) {
            UserInfo storage user = userInfo[msg.sender];
            uint256 userAmount = user.amount;
            uint256 shares = userAmount * (100 + user.bonus) / 100;
            uint256 newShares = (userAmount + liquidity) * (100 + user.bonus) / 100;
            totalShares = totalShares + newShares - shares;
            user.amount = userAmount + liquidity;
            emit Staked(msg.sender, liquidity);            
        }
    }

    function reinvestSoyPool(uint256 reinvestAmount, address tokenOut) internal returns(uint256 liquidity) {
        (uint256 reserveIn, uint256 reserveOut,) = ISoyFinancePair(lpToken).getReserves();
        if (tokenOut < address(rewardsToken)) {
            (reserveIn, reserveOut) = (reserveOut, reserveIn);
        }
        uint256 amountIn = calcAmountIn(reinvestAmount, reserveIn);
        uint256 amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        // swap Soy to pair token
        swap(address(lpToken), amountIn, amountOut, tokenOut);


        // add liquidity
        amountIn = reinvestAmount - amountIn;
        rewardsToken.transfer(address(lpToken), amountIn);
        IERC223(tokenOut).transfer(address(lpToken), amountOut);
        liquidity = ISoyFinancePair(lpToken).mint(address(this));
    }

    function reinvestPools(uint256 rewardReinvested, address token0, address token1) internal returns(uint256 liquidity) {
        (uint256 pA, uint256 pB, address pair) = getReserves(token0, token1);
        require (pair == address(lpToken), "wrong factory");
        (uint256 aI, uint256 aO, address pairA) = getReserves(address(rewardsToken), token0);
        (uint256 bI, uint256 bO, address pairB) = getReserves(address(rewardsToken), token1);

        // calculate amounts In and Out        
        (aI, aO, bI, bO) = calcAmounts(rewardReinvested, aI, aO, bI, bO, pA, pB);

        // swap Soy to required tokens
        swap(pairA, aI, aO, token0);
        swap(pairB, bI, bO, token1);

        // add liquidity
        IERC223(token0).transfer(address(lpToken), aO);
        IERC223(token1).transfer(address(lpToken), bO);
        liquidity = ISoyFinancePair(lpToken).mint(address(this));
    }

    // swap rewardsToken (SOY) to pair token (tokenOut)
    function swap(address pair, uint256 amountIn, uint256 amountOut, address tokenOut) internal {
        rewardsToken.transfer(pair, amountIn);
        (uint256 amount0Out, uint256 amount1Out) = address(rewardsToken) < tokenOut ? (uint256(0), amountOut) : (amountOut, uint256(0));
        ISoyFinancePair(pair).swap(amount0Out, amount1Out, address(this), new bytes(0));
    }

}
