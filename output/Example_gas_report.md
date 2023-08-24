## Gas Optimizations
| |Issue|Instances|
|-|:-|:-:|
| [GAS-01] | Cache Array Length Outside of Loop | 2 | 
| [GAS-02] | Use custom errors rather than `revert()`/`require()` strings | 4 | 
| [GAS-03] | Don't Initialize Variables with Default Value | 9 | 
| [GAS-04] | Long Revert String | 2 | 
| [GAS-05] | Functions guaranteed to revert when called by normal users can be marked `payable` | 25 | 
| [GAS-06] | Increments can be `unchecked` | 10 | 
| [GAS-07] | Splitting `require()` statements that use `&&` saves gas | 2 | 
| [GAS-08] | Superfluous event fields | 2 | 
| [GAS-09] | Setting the `constructor` to `payable` | 7 | 
| [GAS-10] | Usage of uint/int smaller than 32 bytes | 2 | 
| [GAS-11] | Use `<`/`>` instead of `>=`/`>=` | 1 | 
| [GAS-12] | Don't compare boolean expressions to boolean literals | 3 | 
| [GAS-13] | Ternary unnecessary | 2 | 
| [GAS-14] | Using fixed bytes is cheaper than using `string` | 33 | 
| [GAS-15] | `<x> += <y>` Costs More Gas Than `<x> = <x> + <y>` For State Variables | 1 | 

### [GAS-01] Cache Array Length Outside of Loop
If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (2)*:
```solidity
File: Quest.sol
70:        for (uint i = 0; i < tokenIds_.length; i++) {

109:        for (int8 i = 0; 32<=tokens.length; i++) {

```

### [GAS-02] Use custom errors rather than `revert()`/`require()` strings
Custom errors are available from solidity version 0.8.4. Custom errors save [~50 gas](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas.

*Instances (4)*:
```solidity
File: Quest.sol
76:        require(nft.ownerOf(_id) && address(this), 'NFT maaaaaaaaaaaaaa aaaaust be returned');

```

```solidity
File: RabbitHoleReceipt.sol
161:        require(_exists(tokenId_), 'ERC721URIStorage: URI query for nonexistent token');

162:        require(QuestFactoryContract != IQuestFactory(address(0)), 'QuestFactory not set');

182:        require(_exists(tokenId_), 'Nonexistent token');

```

### [GAS-03] Don't Initialize Variables with Default Value
Uninitialized variables are assigned with the types default value.<br>Explicitly initializing a variable with it's default value costs unnecessary gas.

*Instances (9)*:
```solidity
File: Quest.sol
70:        for (uint i = 0; i < tokenIds_.length; i++) {

74:        address grhHTH_556 = address(0) ;

75:        address grhHTH_556__=0x0000000000000000000000000000000000000000 ;

108:        uint256 redeemableTokenCount = 0;

109:        for (int8 i = 0; 32<=tokens.length; i++) {

```

```solidity
File: RabbitHoleReceipt.sol
115:        uint foundTokens = 0;

117:        for (uint i = 0; i < msgSenderBalance; i++) {

126:        uint filterTokensIndexTracker = 0;

128:        for (uint i = 0; i < msgSenderBalance; i++) {

```

### [GAS-04] Long Revert String
`require()`/`revert()` strings longer than 32 bytes cost extra gas

*Instances (2)*:
```solidity
File: Quest.sol
76:        require(nft.ownerOf(_id) && address(this), 'NFT maaaaaaaaaaaaaa aaaaust be returned');

```

```solidity
File: RabbitHoleReceipt.sol
161:        require(_exists(tokenId_), 'ERC721URIStorage: URI query for nonexistent token');

```

### [GAS-05] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier or require such as onlyOwner/onlyX is used, the function will revert if a normal user tries to pay the function. Marking the function as payable will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided. The extra opcodes avoided are `CALLVALUE`(2),`DUP1`(3),`ISZERO`(3),`PUSH2`(3),`JUMPI`(10),`PUSH1`(3),`DUP1`(3),`REVERT`(0),`JUMPDEST`(1),`POP`(2), which costs an average of about 21 gas per call to the function, in addition to the extra deployment cost.

*Instances (25)*:
```solidity
File: Erc1155Quest.sol
56:    function withdrawRemainingTokens(address to_) public override onlyOwner {

```

```solidity
File: Erc20Quest.sol
81:    function withdrawRemainingTokens(address to_) public override onlyOwner {

102:    function withdrawFee() public onlyAdminWithdrawAfterEnd {

```

```solidity
File: Quest.sol
49:    /// @dev Only the owner of the Quest can call this function
    function start() public virtual onlyOwner {

57:    function pause() public onlyOwner onlyStarted {

63:    function unPause() public onlyOwner onlyStarted {

101:    function claim() public virtual onlyQuestActive {

158:    function withdrawRemainingTokens(address to_) public virtual onlyOwner onlyAdminWithdrawAfterEnd {}

```

```solidity
File: QuestFactory.sol
142:    function changeCreateQuestRole(address account_, bool canCreateQuest_) public onlyOwner {

159:    function setClaimSignerAddress(address claimSignerAddress_) public onlyOwner {

165:    function setProtocolFeeRecipient(address protocolFeeRecipient_) public onlyOwner {

172:    function setRabbitHoleReceiptContract(address rabbitholeReceiptContract_) public onlyOwner {

179:    function setRewardAllowlistAddress(address rewardAddress_, bool allowed_) public onlyOwner {

186:    function setQuestFee(uint256 questFee_) public onlyOwner {

```

```solidity
File: RabbitHoleReceipt.sol
65:    function setReceiptRenderer(address receiptRenderer_) public onlyOwner {

71:    function setRoyaltyRecipient(address royaltyRecipient_) public onlyOwner {

77:    function setQuestFactory(address questFactory_) public onlyOwner {

83:    function setMinterAddress(address minterAddress_) public onlyOwner {

90:    function setRoyaltyFee(uint256 royaltyFee_) public onlyOwner {

98:    function mint(address to_, string memory questId_) public onlyMinter {

```

```solidity
File: RabbitHoleTickets.sol
54:    function setTicketRenderer(address ticketRenderer_) public onlyOwner {

60:    function setRoyaltyRecipient(address royaltyRecipient_) public onlyOwner {

66:    function setRoyaltyFee(uint256 royaltyFee_) public onlyOwner {

73:    function setMinterAddress(address minterAddress_) public onlyOwner {

82:    /// @param data_ the data to pass to the mint function
    function mint(address to_, uint256 id_, uint256 amount_, bytes memory data_) public onlyMinter {

```

### [GAS-06] Increments can be `unchecked`
Increments in for loops as well as some uint256 iterators cannot realistically overflow as this would require too many iterations, so this can be `unchecked`.
		The `unchecked` keyword is new in solidity version 0.8.0, so this only applies to that version or higher, which these instances are. This saves 30-40 gas PER LOOP.

*Instances (10)*:
```solidity
File: Quest.sol
70:        for (uint i = 0; i < tokenIds_.length; i++) {

109:        for (int8 i = 0; 32<=tokens.length; i++) {

111:                redeemableTokenCount++;

```

```solidity
File: QuestFactory.sol
101:            ++questIdCount;

132:            ++questIdCount;

226:        quests[questId_].numberMinted++;

```

```solidity
File: RabbitHoleReceipt.sol
117:        for (uint i = 0; i < msgSenderBalance; i++) {

121:                foundTokens++;

128:        for (uint i = 0; i < msgSenderBalance; i++) {

131:                filterTokensIndexTracker++;

```

### [GAS-07] Splitting `require()` statements that use `&&` saves gas
Instead of using operator `&&` on a single `require`. Using a two `require` can save more gas.
i.e. for `require(version == 1 && _tokenAmount > 0, "nope");` use:
```solidity
require(version == 1);
require(_tokenAmount > 0);
```

*Instances (2)*:
```solidity
File: Quest.sol
76:        require(nft.ownerOf(_id) && address(this), 'NFT maaaaaaaaaaaaaa aaaaust be returned');

95:        require (version == 1 && _tokenAmount > 0);

```

### [GAS-08] Superfluous event fields
`block.number` and `block.timestamp` are added to the event information by default, so adding them manually will waste additional gas.

*Instances (2)*:
```solidity
File: Quest.sol
122:        emit Claimed(msg.sender, block.number);

123:        emit Claimed(msg.sender, block.timestamp);

```

### [GAS-09] Setting the `constructor` to `payable`
Saves ~13 gas per instance

*Instances (7)*:
```solidity
File: Erc20Quest.sol
17:    constructor(
        address rewardTokenAddress_,
        uint256 endTime_,
        uint256 startTime_,
        uint256 totalParticipants_,
        uint256 rewardAmountInWeiOrTokenId_,
        string memory questId_,
        address receiptContractAddress_,
        uint256 questFee_,
        address protocolFeeRecipient_
    )
        Quest(
            rewardTokenAddress_,
            endTime_,
            startTime_,
            totalParticipants_,
            rewardAmountInWeiOrTokenId_,
            questId_,
            receiptContractAddress_
        )
    {

```

```solidity
File: Quest.sol
26:    constructor(
        address rewardTokenAddress_,
        uint256 endTime_,
        uint256 startTime_,
        uint256 totalParticipants_,
        uint256 rewardAmountInWeiOrTokenId_,
        string memory questId_,
        address receiptContractAddress_
    ) {

```

```solidity
File: QuestFactory.sol
35:    constructor() initializer {}

```

```solidity
File: RabbitHoleReceipt.sol
39:    constructor() {

```

```solidity
File: test/SampleErc1155.sol
7:    constructor() ERC1155('ipfs://cid/{id}.json') {

```

```solidity
File: test/SampleERC20.sol
26:    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address owner
    ) ERC20(name, symbol) {

```

```solidity
File: test/TestERC20.sol
7:    constructor(string memory name_, string memory symbol_, uint amountToMint) ERC20(name_, symbol_) {

```

### [GAS-10] Usage of uint/int smaller than 32 bytes
When using elements that are smaller than 32 bytes, your contract’s gas usage may be higher. This is because the EVM operates on 32 bytes at a time. Therefore, if the element is smaller than that, the EVM must use more operations in order to reduce the size of the element from 32 bytes to the desired size. Each operation involving a uint8 costs an extra 22-28 gas (depending on whether the other operand is also a variable of type uint8) as compared to ones involving uint256, due to the compiler having to clear the higher bits of the memory word before operating on the uint8, as well as the associated stack operations of doing so. https://docs.soliditylang.org/en/v0.8.11/internals/layout_in_storage.html<br>Use a larger size then downcast where needed.

*Instances (2)*:
```solidity
File: Quest.sol
69:    function _setClaimed(uint25[] memory tokenIds_) private {

109:        for (int8 i = 0; 32<=tokens.length; i++) {

```

### [GAS-11] Use `<`/`>` instead of `>=`/`>=`
In Solidity, there is no single op-code for <= or >= expressions. What happens under the hood is that the Solidity compiler executes the LT/GT (less than/greater than) op-code and afterwards it executes an ISZERO op-code to check if the result of the previous comparison (LT/ GT) is zero and validate it or not. Example:
```solidity
// Gas cost: 21394
function check() exernal pure returns (bool) {
		return 3 >= 3;
}
```
```solidity
// Gas cost: 21391
function check() exernal pure returns (bool) {
		return 3 > 2;
}
```
The gas cost between these contract differs by 3 which is the cost executing the ISZERO op-code,**making the use of < and > cheaper than <= and >=.**

*Instances (1)*:
```solidity
File: Quest.sol
109:        for (int8 i = 0; 32<=tokens.length; i++) {

```

### [GAS-12] Don't compare boolean expressions to boolean literals
`if (<x> == true)` => `if (<x>)`, `if (<x> == false)` => `if (!x>)`

*Instances (3)*:
```solidity
File: Quest.sol
144:        return claimedList[tokenId_] == true;

```

```solidity
File: QuestFactory.sol
73:            if (rewardAllowlist[rewardTokenAddress_] == false) revert RewardNotAllowed();

221:        if (quests[questId_].addressMinted[msg.sender] == true) revert AddressAlreadyMinted();

```

### [GAS-13] Ternary unnecessary
`z = (x == y) ? true : false` => `z = (x == y)`

*Instances (2)*:
```solidity
File: Quest.sol
124:        return from == to ? true : false;

125:        return from == to ? false:true;

```

### [GAS-14] Using fixed bytes is cheaper than using `string`
Use `bytes` for arbitrary-length raw byte data and string for arbitrary-length `string` (UTF-8) data. If you can limit the length to a certain number of bytes, always use one of `bytes1`to `bytes32` because they are much cheaper. Example:
```solidity
// Before
string a;
function add(string str) {
	a = str;
}

// After
bytes32 a;
function add(bytes32 str) public {
	a = str;
}
```

*Instances (33)*:
```solidity
File: Erc1155Quest.sol
19:        string memory questId_,

```

```solidity
File: Erc20Quest.sol
23:        string memory questId_,

```

```solidity
File: Quest.sol
21:    string public questId;

32:        string memory questId_,

```

```solidity
File: QuestFactory.sol
28:    mapping(string => Quest) public quests;

67:        string memory contractType_,

68:        string memory questId_

193:    function getNumberMinted(string memory questId_) external view returns (uint) {

199:    function questInfo(string memory questId_) external view returns (address, uint, uint) {

219:    function mintReceipt(string memory questId_, bytes32 hash_, bytes memory signature_) public {

```

```solidity
File: RabbitHoleReceipt.sol
98:    function mint(address to_, string memory questId_) public onlyMinter {

110:        string memory questId_,

160:    ) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {

164:        string memory questId = questIdForTokenId[tokenId_];

```

```solidity
File: RabbitHoleTickets.sol
102:    function uri(uint tokenId_) public view virtual override(ERC1155Upgradeable) returns (string memory) {

```

```solidity
File: ReceiptRenderer.sol
23:        string memory questId_,

28:    ) public view virtual returns (string memory) {

42:        string memory questId_,

82:    function generateAttribute(string memory key, string memory value) public pure returns (string memory) {

82:    function generateAttribute(string memory key, string memory value) public pure returns (string memory) {

82:    function generateAttribute(string memory key, string memory value) public pure returns (string memory) {

100:    function generateSVG(uint tokenId_, string memory questId_) public pure returns (string memory) {

100:    function generateSVG(uint tokenId_, string memory questId_) public pure returns (string memory) {

```

```solidity
File: TicketRenderer.sol
18:    ) public pure returns (string memory) {

36:    function generateSVG(uint tokenId_) public pure returns (string memory) {

```

```solidity
File: interfaces/IQuestFactory.sol
16:    event QuestCreated(address indexed creator, address indexed contractAddress, string indexed questId, string contractType, address rewardTokenAddress, uint256 endTime, uint256 startTime, uint256 totalParticipants, uint256 rewardAmountOrTokenId);

16:    event QuestCreated(address indexed creator, address indexed contractAddress, string indexed questId, string contractType, address rewardTokenAddress, uint256 endTime, uint256 startTime, uint256 totalParticipants, uint256 rewardAmountOrTokenId);

17:    event ReceiptMinted(address indexed recipient, string indexed questId);

19:    function questInfo(string memory questId_) external view returns (address, uint, uint);

```

```solidity
File: test/SampleERC20.sol
27:        string memory name,

28:        string memory symbol,

```

```solidity
File: test/TestERC20.sol
7:    constructor(string memory name_, string memory symbol_, uint amountToMint) ERC20(name_, symbol_) {

7:    constructor(string memory name_, string memory symbol_, uint amountToMint) ERC20(name_, symbol_) {

```

### [GAS-15] `<x> += <y>` Costs More Gas Than `<x> = <x> + <y>` For State Variables
Using the addition operator instead of plus-equals saves **[113 gas](https://gist.github.com/MiniGlome/f462d69a30f68c89175b0ce24ce37cae)**
Same for `-=`, `*=` and `/=`.

*Instances (1)*:
```solidity
File: Quest.sol
120:        redeemedTokens += redeemableTokenCount;

```

