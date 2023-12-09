issues = [
	{
		"code": "G01",
		"title": "Cache Array Length Outside of Loop",
		"description": "If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).",
		"regex": "for.*\.length.*",
	},
	{
		"code": "G02",
		"title": "Use custom errors rather than `revert()`/`require()` strings",
		"description": "Custom errors are available from solidity version 0.8.4. Custom errors save [~50 gas](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas.",
		"regex": "(revert|require)\s*\(((?!;).|(?!;)\n)*(\".*\"|'.*')((?!;).|(?!;)\n)*\)\s*;",
	},
	{
		"code": "G03",
		"title": "Don't Initialize Variables with Default Value",
		"description": "Uninitialized variables are assigned with the types default value.<br>Explicitly initializing a variable with it's default value costs unnecessary gas.",
		"regex": '(u?int[0-9]*\s+(\w|\s)*=\s*0\s*;)|(bool\s+(\w|\s)*=\s*false\s*;)|(address\s+(\w|\s)*=\s*(0x0{40}|address\(0\))\s*;)',
	},
	{
		"code": "G04",
		"title": "Long Revert String",
		"description": "`require()`/`revert()` strings longer than 32 bytes cost extra gas",
		"regex": "(require|revert).*((\".{33,}\")|(\'.{33,}\'))",
	},
	{
		"code": "G05",
		"title": "Functions guaranteed to revert when called by normal users can be marked `payable`",
		"description": "If a function modifier or require such as onlyOwner/onlyX is used, the function will revert if a normal user tries to pay the function. Marking the function as payable will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided. The extra opcodes avoided are `CALLVALUE`(2),`DUP1`(3),`ISZERO`(3),`PUSH2`(3),`JUMPI`(10),`PUSH1`(3),`DUP1`(3),`REVERT`(0),`JUMPDEST`(1),`POP`(2), which costs an average of about 21 gas per call to the function, in addition to the extra deployment cost.",
		"regex": "function\s.*\sonly\w+",
	},
	{
		"code": "G06",
		"title": "Use Shift Right/Left instead of Division/Multiplication if possible",
		"description": "A division/multiplication by any number `x` being a power of 2 can be calculated by shifting `log2(x)` to the right/left.<br>While the `DIV` opcode uses 5 gas, the `SHR` opcode only uses 3 gas. Furthermore, Solidity's division operation also includes a division-by-0 prevention which is bypassed using shifting.",
		"regex": "[\w\d]( )*[/\*]\s*(2|4|8|16|32|64|128|256)\D",
	},
	{
		"code": "G07",
		"title": "Increments can be `unchecked`",
		"description": """Increments in for loops as well as some uint256 iterators cannot realistically overflow as this would require too many iterations, so this can be `unchecked`.
		The `unchecked` keyword is new in solidity version 0.8.0, so this only applies to that version or higher, which these instances are. This saves 30-40 gas PER LOOP.""",
		"regex": "\+\+",
	},
	{
		"code": "G08",
		"title": "Splitting `require()` statements that use `&&` saves gas",
"description": """Instead of using operator `&&` on a single `require`. Using a two `require` can save more gas.
i.e. for `require(version == 1 && _tokenAmount > 0, "nope");` use:
```solidity
require(version == 1);
require(_tokenAmount > 0);
```""",
		"regex": "require.*&&((?!;).|(?!;)\n)*;",
	},
	{
		"code": "G09",
		"title": "Superfluous event fields",
		"description": "`block.number` and `block.timestamp` are added to the event information by default, so adding them manually will waste additional gas.",
		"regex": "emit.*block\.(number|timestamp)",
	},
	{
		"code": "G10",
		"title": "Setting the `constructor` to `payable`",
		"description": "Saves ~13 gas per instance",
		"regex": "constructor\s*\(((?!payable).|(?!payable)\n)*?\{",
	},
	{
		"code": "G11",
		"title": "Usage of uint/int smaller than 32 bytes",
		"description": "When using elements that are smaller than 32 bytes, your contract’s gas usage may be higher. This is because the EVM operates on 32 bytes at a time. Therefore, if the element is smaller than that, the EVM must use more operations in order to reduce the size of the element from 32 bytes to the desired size. Each operation involving a uint8 costs an extra 22-28 gas (depending on whether the other operand is also a variable of type uint8) as compared to ones involving uint256, due to the compiler having to clear the higher bits of the memory word before operating on the uint8, as well as the associated stack operations of doing so. https://docs.soliditylang.org/en/v0.8.11/internals/layout_in_storage.html<br>Use a larger size then downcast where needed.",
		"regex": "\W(u?int[1-9]|u?int[1-2][0-9]|u?int3[0-1])\W",
	},
	{
		"code": "G12",
		"title": "Use `<`/`>` instead of `>=`/`>=`",
		"description": """In Solidity, there is no single op-code for <= or >= expressions. What happens under the hood is that the Solidity compiler executes the LT/GT (less than/greater than) op-code and afterwards it executes an ISZERO op-code to check if the result of the previous comparison (LT/ GT) is zero and validate it or not. Example:
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
The gas cost between these contract differs by 3 which is the cost executing the ISZERO op-code,**making the use of < and > cheaper than <= and >=.**""",
		"regex": "[<>]=\s*\d+|\d+\s*[<>]=",
	},
	{
		"code": "G13",
		"title": "Don't compare boolean expressions to boolean literals",
		"description": "`if (<x> == true)` => `if (<x>)`, `if (<x> == false)` => `if (!x>)`",
		"regex": "[!=]=\s*(true|false)|(true|false)\s*[!=]=",
	},
	{
		"code": "G14",
		"title": "Ternary unnecessary",
		"description": "`z = (x == y) ? true : false` => `z = (x == y)`",
		"regex": "\?\s*(true|false)\s*:\s*(true|false)",
	},
	{
		"code": "G15",
		"title": "Using fixed bytes is cheaper than using `string`",
		"description": """Use `bytes` for arbitrary-length raw byte data and string for arbitrary-length `string` (UTF-8) data. If you can limit the length to a certain number of bytes, always use one of `bytes1`to `bytes32` because they are much cheaper. Example:
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
```""",
		"regex": "string\s",
	},
	{
		"code": "G16",
		"title": "`<x> += <y>` Costs More Gas Than `<x> = <x> + <y>` For State Variables",
		"description": "Using the addition operator instead of plus-equals saves **[113 gas](https://gist.github.com/MiniGlome/f462d69a30f68c89175b0ce24ce37cae)**\nSame for `-=`, `*=` and `/=`.",
		"regex": "(?<!]\s)[+\-\*/]=",
	},
	{
		"code": "G17",
		"title": "Casting block.timestamp can save you some gas",
		"description": "block.timestamp can be cast to a uint48 or even uint32 that is still valid for the year 2106.",
		"regex": "(?!(uint48|uint32)[(])block\.timestamp",
	},
	{
		"code": "G18",
		"title": "Consider replacing `<x> % 2` with `<x> & uint(1)`",
		"description": "You can save around 175 gas by using `<x> & uint(1)` instead of `<x> % 2`",
		"regex": "%\s?2",
	},
	{
		"code": "G19",
		"title": "abi.encodePacked is more gas efficient than abi.encode",
		"description": "You can save around 175 gas by using abi.encodePacked instead of abi.encode",
		"regex": "abi\.encode\(",
	},

]
