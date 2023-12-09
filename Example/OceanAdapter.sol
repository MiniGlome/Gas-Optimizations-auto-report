// SPDX-License-Identifier: MIT
// Cowri Labs Inc.

pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../ocean/IOceanPrimitive.sol";
import "../ocean/Interactions.sol";

/**
 * @notice
 *   Helper contract for shell adapters
 */
abstract contract OceanAdapter is IOceanPrimitive {
    /// @notice normalized decimals to be compatible with the Ocean.
    uint8 constant NORMALIZED_DECIMALS = 18;

    /// @notice Ocean address.
    address public immutable ocean;

    /// @notice external primitive address.
    address public immutable primitive;

    /// @notice The underlying token address corresponding to the Ocean ID.
    mapping(uint256 => address) public underlying;

    //*********************************************************************//
    // ---------------------------- constructor -------------------------- //
    //*********************************************************************//

    /// @notice only initializing the immutables
    constructor(address ocean_, address primitive_) {
        ocean = ocean_;
        primitive = primitive_;
    }

    /// @notice only allow the Ocean to call a method
    modifier onlyOcean() {
        require(msg.sender == ocean);
        _;
    }

    /**
     * @dev The Ocean must always know the input and output tokens in order to
     *  do the accounting.  One of the token amounts is chosen by the user, and
     *  the other amount is chosen by the primitive.  When computeOutputAmount is
     *  called, the user provides the inputAmount, and the primitive uses this to
     *  compute the outputAmount
     * @param inputToken The user is giving this token to the primitive
     * @param outputToken The primitive is giving this token to the user
     * @param inputAmount The amount of the inputToken the user is giving to the primitive
     * @param metadata a bytes32 value that the user provides the Ocean
     * @dev the unused param is an address field called userAddress
     */
    function computeOutputAmount(
        uint256 inputToken,
        uint256 outputToken,
        uint256 inputAmount,
        address,
        bytes32 metadata
    )
        external
        override
        onlyOcean
        returns (uint256 outputAmount)
    {
        unwrapToken(inputToken, inputAmount);

        // handle the unwrap fee scenario
        uint256 unwrapFee = inputAmount / IOceanInteractions(ocean).unwrapFeeDivisor();
        uint256 unwrappedAmount = inputAmount - unwrapFee;

        outputAmount = primitiveOutputAmount(inputToken, outputToken, unwrappedAmount, metadata);

        wrapToken(outputToken, outputAmount);
    }

    /**
     * @notice Not implemented for this primitive
     */
    function computeInputAmount(
        uint256 inputToken,
        uint256 outputToken,
        uint256 outputAmount,
        address userAddress,
        bytes32 maximumInputAmount
    )
        external
        override
        onlyOcean
        returns (uint256 inputAmount)
    {
        revert();
    }

    /**
     * @notice used to fetch the Ocean interaction ID
     */
    function _fetchInteractionId(address token, uint256 interactionType) internal pure returns (bytes32) {
        uint256 packedValue = uint256(uint160(token));
        packedValue |= interactionType << 248;
        return bytes32(abi.encode(packedValue));
    }

    /**
     * @notice calculates Ocean ID for a underlying token
     */
    function _calculateOceanId(address tokenAddress, uint256 tokenId) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(tokenAddress, tokenId)));
    }

    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     * @notice returning 0 here since this primitive should not have any tokens
     */
    function getTokenSupply(uint256 tokenId) external view override returns (uint256) {
        return 0;
    }

    /**
     * @dev convert a uint256 from one fixed point decimal basis to another,
     *   returning the truncated amount if a truncation occurs.
     * @dev fn(from, to, a) => b
     * @dev a = (x * 10**from) => b = (x * 10**to), where x is constant.
     * @param amountToConvert the amount being converted
     * @param decimalsFrom the fixed decimal basis of amountToConvert
     * @param decimalsTo the fixed decimal basis of the returned convertedAmount
     * @return convertedAmount the amount after conversion
     */
    function _convertDecimals(
        uint8 decimalsFrom,
        uint8 decimalsTo,
        uint256 amountToConvert
    )
        internal
        pure
        returns (uint256 convertedAmount)
    {
        if (decimalsFrom == decimalsTo) {
            // no shift
            convertedAmount = amountToConvert;
        } else if (decimalsFrom < decimalsTo) {
            // Decimal shift left (add precision)
            uint256 shift = 10 ** (uint256(decimalsTo - decimalsFrom));
            convertedAmount = amountToConvert * shift;
        } else {
            // Decimal shift right (remove precision) -> truncation
            uint256 shift = 10 ** (uint256(decimalsFrom - decimalsTo));
            convertedAmount = amountToConvert / shift;
        }
    }

    function primitiveOutputAmount(
        uint256 inputToken,
        uint256 outputToken,
        uint256 inputAmount,
        bytes32 metadata
    )
        internal
        virtual
        returns (uint256 outputAmount);

    function wrapToken(uint256 tokenId, uint256 amount) internal virtual;

    function unwrapToken(uint256 tokenId, uint256 amount) internal virtual;
}
