// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.2;

import "./BaseMeeting.sol";
import "./Validator.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/**
 * @title MeetingContract
 * @dev Meeting contract which ...
 **/

contract Meeting is
    Initializable,
    BaseMeeting,
    PausableUpgradeable,
    OwnableUpgradeable,
    Validator,
    ReentrancyGuardUpgradeable
{
    /*
     * @dev: Constructor, sets operator
     *
     * @param _validator: list backend wallets
     */
    function initialize(address[] memory _validator) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        for (uint256 i; i < _validator.length; i++) {
            addValidator(_validator[i]);
        }
    }

    /*
     * @dev: Add validator
     *
     */
    function addValidator(address _newValidator) public onlyOwner {
        _addValidator(_newValidator);
    }

    /*
     * @dev: Remove validator
     *
     */
    function removeValidator(address _validator) public onlyOwner {
        _removeValidator(_validator);
    }

    /*
     * @dev: Fallback function allows anyone to send funds to the bank directly
     *
     */

    /**
     * @dev Pauses all functions.
     * Set timestamp for current pause
     * No need to reset pausedAt when pausing it will automatically increase
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all functions.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /*
     * @dev: Create new a meeting
     */

    function createNoSign(
        uint256 _meeting_id,
        string memory _title,
        uint256 _start_time,
        uint256 _end_time,
        string memory _meeting_link,
        uint256 _company_id,
        uint256 _shareholders_totals,
        uint256 _shareholders_joined,
        uint256 _total_meeting_shares,
        uint256 _joined_meeting_shares
    ) public whenNotPaused nonReentrant onlyOperator {
        require(!meetings[_meeting_id].exsited, "err: meeting exsited");
        createMeeting(
            _meeting_id,
            _title,
            _start_time,
            _end_time,
            _meeting_link,
            _company_id,
            _shareholders_totals,
            _shareholders_joined,
            _total_meeting_shares,
            _joined_meeting_shares
        );
    }

    function updateNoSign(
        uint256 _meeting_id,
        string memory _title,
        uint256 _start_time,
        uint256 _end_time,
        string memory _meeting_link,
        uint256 _company_id,
        uint256 _shareholders_totals,
        uint256 _shareholders_joined,
        uint256 _total_meeting_shares,
        uint256 _joined_meeting_shares
    ) public whenNotPaused nonReentrant onlyOperator {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        updateMeeting(
            _meeting_id,
            _title,
            _start_time,
            _end_time,
            _meeting_link,
            _company_id,
            _shareholders_totals,
            _shareholders_joined,
            _total_meeting_shares,
            _joined_meeting_shares
        );
    }

    function addProposalsNoSign(
        uint256 _meeting_id,
        ProposalMeetingData[] memory _newProposals,
        uint256 _step
    ) public whenNotPaused nonReentrant onlyOperator {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        addProposals(_meeting_id, _newProposals, _step);
    }

    function addUserNoSign(
        uint256 _meeting_id,
        ParticipantMeetingData[] memory _newParticipantMeetings,
        uint256 _step
    ) public whenNotPaused nonReentrant onlyOperator {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        addParticipantMeetings(_meeting_id, _newParticipantMeetings, _step);
    }

    function addUserProposalNoSign(
        uint256 _proposal_id,
        ParticipantVotingData[] memory _newParticipantProposals,
        uint256 _step
    ) public whenNotPaused nonReentrant onlyOperator {
        require(proposals[_proposal_id].exsited, "err: meeting not exsited");
        addParticipantProposals(_proposal_id, _newParticipantProposals, _step);
    }

    function addFileProposalNoSign(
        uint256 _meeting_id,
        FileOfProposalData[] memory _newFileProposals,
        uint256 _step
    ) public whenNotPaused nonReentrant onlyOperator {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        addFileOfProposalMeetings(_meeting_id, _newFileProposals, _step);
    }

    function addFileMeetingNoSign(
        uint256 _meeting_id,
        FileOfMeetingData[] memory _newFileMeetings,
        uint256 _step
    ) public whenNotPaused nonReentrant onlyOperator {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        addFileMeetings(_meeting_id, _newFileMeetings, _step);
    }

    /*
     * @dev: For everyone to get the meeting data in order to verify
     *       if it is correct data that they need to verify with signature
     *
     * @param _meetind_id: id of the Meeting
     * @return meetingData
     */
    function getMeetingData(
        uint256 _meeting_id
    ) public view returns (MeetingData memory) {
        return _getMeetingData(_meeting_id);
    }

    /*
     * @dev: For everyone to get the meeting data in order to verify
     *       if it is correct data that they need to verify with signature
     *
     * @param _meetind_id: id of the Meeting
     * @return ProposalMeetingData
     */
    function getProposalMeetingData(
        uint256 _meeting_id
    ) public view returns (ProposalMeetingData[] memory) {
        return _getProposalByMeetingId(_meeting_id);
    }

    /*
     * @dev: For everyone to get the meeting data in order to verify
     *       if it is correct data that they need to verify with signature
     *
     * @param _meetind_id: id of the Meeting
     * @return ParticipantMeetingData
     */
    function getUserInfoData(
        uint256 _meeting_id
    ) public view returns (ParticipantMeetingData[] memory) {
        return _getUserInfoByMeetingId(_meeting_id);
    }

    /*
     * @dev: For everyone to get the meeting data in order to verify
     *       if it is correct data that they need to verify with signature
     *
     * @param _meetind_id: id of the Meeting
     * @return FileOfProposalData
     */
    function getFileProposalData(
        uint256 _meeting_id
    ) public view returns (FileOfProposalData[] memory) {
        return _getFileProposalByMeetingId(_meeting_id);
    }

    function getFileMeetingData(
        uint256 _meeting_id
    ) public view returns (FileOfMeetingData[] memory) {
        return _getFileMeetingByMeetingId(_meeting_id);
    }

    // This function check the mapping to see if the meeting_id is exsited
    function checkIsCreated(
        uint256 _meetind_id
    ) public view returns (bool, uint256) {
        return (meetings[_meetind_id].exsited, _meetind_id);
    }
}
