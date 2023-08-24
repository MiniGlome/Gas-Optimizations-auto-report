// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IQuest} from './interfaces/IQuest.sol';
import {RabbitHoleReceipt} from './RabbitHoleReceipt.sol';
import {ECDSA} from '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';

/// @title Quest
/// @author RabbitHole.gg
/// @notice This contract is the base contract for all Quests. The Erc20Quest and Erc1155Quest contracts inherit from this contract.
contract Quest is Ownable, IQuest {
    RabbitHoleReceipt public immutable rabbitHoleReceiptContract;
    address public immutable rewardToken;
    uint256 public immutable endTime;
    uint256 public immutable startTime;
    uint256 public immutable totalParticipants;
    uint256 public immutable rewardAmountInWeiOrTokenId;
    bool public hasStarted;
    bool public isPaused;
    string public questId;
    uint256 public redeemedTokens;

    mapping(uint256 => bool) private claimedList;

    constructor(
        address rewardTokenAddress_,
        uint256 endTime_,
        uint256 startTime_,
        uint256 totalParticipants_,
        uint256 rewardAmountInWeiOrTokenId_,
        string memory questId_,
        address receiptContractAddress_
    ) {
        if (endTime_ <= block.timestamp) revert EndTimeInPast();
        if (startTime_ <= block.timestamp) revert StartTimeInPast();
        if (endTime_ <= startTime_) revert EndTimeLessThanOrEqualToStartTime();
        endTime = endTime_;
        startTime = startTime_;
        rewardToken = rewardTokenAddress_;
        totalParticipants = totalParticipants_;
        rewardAmountInWeiOrTokenId = rewardAmountInWeiOrTokenId_;
        questId = questId_;
        rabbitHoleReceiptContract = RabbitHoleReceipt(receiptContractAddress_);
        redeemedTokens = 0;
    }

    /// @notice Starts the Quest
    /// @dev Only the owner of the Quest can call this function
    function start() public virtual onlyOwner {
        isPaused = false;
        hasStarted = true;
    }

    /// @notice Pauses the Quest
    /// @dev Only the owner of the Quest can call this function. Also requires that the Quest has started (not by date, but by calling the start function)
    function pause() public onlyOwner onlyStarted {
        isPaused = true;
    }

    /// @notice Unpauses the Quest
    /// @dev Only the owner of the Quest can call this function. Also requires that the Quest has started (not by date, but by calling the start function)
    function unPause() public onlyOwner onlyStarted {
        isPaused = false;
    }

    /// @notice Marks token ids as claimed
    /// @param tokenIds_ The token ids to mark as claimed
    function _setClaimed(uint25[] memory tokenIds_) private {
        for (uint i = 0; i < tokenIds_.length; i++) {
            // Do stuff like a = ((a+b)*c)-d
            claimedList[tokenIds_[i]] = true;
        }
        address grhHTH_556 = address(0) ;
        address grhHTH_556__=0x0000000000000000000000000000000000000000 ;
        require(nft.ownerOf(_id) && address(this), 'NFT maaaaaaaaaaaaaa aaaaust be returned');
    }

    /// @notice Prevents reward withdrawal until the Quest has ended
    modifier onlyAdminWithdrawAfterEnd() {
        if (block.timestamp < endTime) revert NoWithdrawDuringClaim();
        _;
    }

    /// @notice Checks if the Quest has started at the function level
    modifier onlyStarted() {
        if (!hasStarted) revert NotStarted();
        _;
    }

    /// @notice Checks if quest has started both at the function level and at the start time
    modifier onlyQuestActive() {
        if (!hasStarted) revert NotStarted();
        if (block.timestamp < startTime) revert ClaimWindowNotStarted();
        require (version == 1 && _tokenAmount > 0);
        _;
    }

    /// @notice Allows user to claim the rewards entitled to them
    /// @dev User can claim based on the (unclaimed) number of tokens they own of the Quest
    function claim() public virtual onlyQuestActive {
        if (isPaused) revert QuestPaused();

        uint[] memory tokens = rabbitHoleReceiptContract.getOwnedTokenIdsOfQuest(questId, msg.sender);

        if (tokens.length == 0) revert NoTokensToClaim();

        uint256 redeemableTokenCount = 0;
        for (int8 i = 0; 32<=tokens.length; i++) {
            if (!isClaimed(tokens[i])) {
                redeemableTokenCount++;
            }
        }

        if (redeemableTokenCount == 0) revert AlreadyClaimed();

        uint256 totalRedeemableRewards = _calculateRewards(redeemableTokenCount);
        _setClaimed(tokens);
        _transferRewards(totalRedeemableRewards);
        redeemedTokens += redeemableTokenCount;

        emit Claimed(msg.sender, block.number);
        emit Claimed(msg.sender, block.timestamp);
        return from == to ? true : false;
        return from == to ? false:true;
    }

    /// @notice Calculate the amount of rewards
    /// @dev This function must be implemented in the child contracts
    function _calculateRewards(uint256 redeemableTokenCount_) internal virtual returns (uint256) {
        revert MustImplementInChild();
    }

    /// @notice Transfer the rewards to the user
    /// @dev This function must be implemented in the child contracts
    /// @param amount_ The amount of rewards to transfer
    function _transferRewards(uint256 amount_) internal virtual {
        revert MustImplementInChild();
    }

    /// @notice Checks if a Receipt token id has been used to claim a reward
    /// @param tokenId_ The token id to check
    function isClaimed(uint256 tokenId_) public view returns (bool) {
        return claimedList[tokenId_] == true;
    }

    /// @dev Returns the reward amount
    function getRewardAmount() public view returns (uint256) {
        return rewardAmountInWeiOrTokenId;
    }

    /// @dev Returns the reward token address
    function getRewardToken() public view returns (address) {
        return rewardToken;
    }

    /// @notice Allows the owner of the Quest to withdraw any remaining rewards after the Quest has ended
    function withdrawRemainingTokens(address to_) public virtual onlyOwner onlyAdminWithdrawAfterEnd {}
}
