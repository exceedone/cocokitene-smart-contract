// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.2;

/*
 *  @title: Storage Data Meeting
 *  @dev: BaseMeeting which ...
 */
contract BaseMeeting {
    struct MeetingData {
        uint256 id;
        string title;
        uint256 start_time;
        uint256 end_time;
        string meeting_link;
        uint256 company_id;
        string[] files;
        bool exsited;
        uint256 shareholders_totals;
        uint256 shareholders_joined;
        uint256 total_meeting_shares;
        uint256 joined_meeting_shares;
        ProposalMeetingData[] proposals;
        uint256 length_proposals;
        ParticipantMeetingData[] participant_meetings;
        uint256 length_participants;
        FileOfProposalData[] file_of_proposals;
        uint256 length_file_of_proposals;
        FileOfMeetingData[] file_of_meetings;
        uint256 length_file_of_meetings;
    }

    struct ProposalData {
        uint256 proposal_id;
        string title;
        uint256 voted_quantity;
        uint256 un_voted_quantity;
        uint256 not_vote_yet_quantity;
        bool exsited;
        uint256 total_participant;
        ParticipantVotingData[] participant_voting;
    }

    struct ProposalMeetingData {
        uint256 proposal_id;
        string title;
        uint256 voted_quantity;
        uint256 un_voted_quantity;
        uint256 not_vote_yet_quantity;
    }

    struct FileOfProposalData {
        uint256 proposal_file_id;
        string url;
    }

    struct ParticipantMeetingData {
        uint256 user_id;
        string user_name;
        string role;
        string status;
    }

    struct ParticipantVotingData {
        uint256 user_id;
        string result;
    }

    struct FileOfMeetingData {
        uint256 meeting_file_id;
        string url;
    }

    // count meeting
    uint256 public totalMeeting;
    // Mapping id_meeting
    mapping(uint256 => MeetingData) internal meetings;
    // count proposal
    uint256 public totalProposal;
    // Mapping proposal_id
    mapping(uint256 => ProposalData) internal proposals;

    /*
     * @dev: Event declarations
     */
    event CreateMeeting(uint256 id_meeting, uint256 numberInBlockchain);
    event UpdateMeeting(uint256 id_meeting);
    event UpdateProposalMeeting(uint256 id_meeting, uint256 step);
    event UpdateFileOfProposalMeeting(uint256 id_meeting, uint256 step);
    event UpdateParticipantMeeting(uint256 id_meeting, uint256 step);
    event UpdateParticipantProposal(uint256 id_proposal, uint256 step);
    event UpdateFileOfMeeting(uint256 id_meeting, uint256 step);

    function createMeeting(
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
    ) internal {
        totalMeeting++;
        MeetingData storage newMeeting = meetings[_meeting_id];
        newMeeting.id = _meeting_id;
        newMeeting.title = _title;
        newMeeting.start_time = _start_time;
        newMeeting.end_time = _end_time;
        newMeeting.meeting_link = _meeting_link;
        newMeeting.company_id = _company_id;
        newMeeting.exsited = true;
        newMeeting.shareholders_totals = _shareholders_totals;
        newMeeting.shareholders_joined = _shareholders_joined;
        newMeeting.total_meeting_shares = _total_meeting_shares;
        newMeeting.joined_meeting_shares = _joined_meeting_shares;

        emit CreateMeeting(_meeting_id, totalMeeting);
    }

    function addProposals(
        uint256 _meeting_id,
        ProposalMeetingData[] memory _newProposals,
        uint256 _step
    ) internal {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        MeetingData storage meeting = meetings[_meeting_id];
        for (uint256 i = 0; i < _newProposals.length; i++) {
            meeting.proposals.push(_newProposals[i]);
            totalProposal++;
            ProposalData storage newProposals = proposals[
                _newProposals[i].proposal_id
            ];
            require(!newProposals.exsited, "err: exsited proposal");
            newProposals.proposal_id = _newProposals[i].proposal_id;
            newProposals.title = _newProposals[i].title;
            newProposals.voted_quantity = _newProposals[i].voted_quantity;
            newProposals.un_voted_quantity = _newProposals[i].un_voted_quantity;
            newProposals.not_vote_yet_quantity = _newProposals[i]
                .not_vote_yet_quantity;
            newProposals.total_participant = 0;
            newProposals.exsited = true;
        }
        meeting.length_proposals += _newProposals.length;
        emit UpdateProposalMeeting(_meeting_id, _step);
    }

    function addParticipantMeetings(
        uint256 _meeting_id,
        ParticipantMeetingData[] memory _newParticipantMeetings,
        uint256 _step
    ) internal {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        MeetingData storage meeting = meetings[_meeting_id];
        for (uint256 i = 0; i < _newParticipantMeetings.length; i++) {
            meeting.participant_meetings.push(_newParticipantMeetings[i]);
        }
        meeting.length_participants += _newParticipantMeetings.length;
        emit UpdateParticipantMeeting(_meeting_id, _step);
    }

    function addParticipantProposals(
        uint256 _proposal_id,
        ParticipantVotingData[] memory _newParticipantProposals,
        uint256 _step
    ) internal {
        require(proposals[_proposal_id].exsited, "err: meeting not exsited");
        ProposalData storage proposal = proposals[_proposal_id];
        for (uint256 i = 0; i < _newParticipantProposals.length; i++) {
            proposal.participant_voting.push(_newParticipantProposals[i]);
        }
        proposal.total_participant += _newParticipantProposals.length;
        emit UpdateParticipantProposal(_proposal_id, _step);
    }

    function addFileOfProposalMeetings(
        uint256 _meeting_id,
        FileOfProposalData[] memory _newFileProposals,
        uint256 _step
    ) internal {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        MeetingData storage meeting = meetings[_meeting_id];
        for (uint256 i = 0; i < _newFileProposals.length; i++) {
            meeting.file_of_proposals.push(_newFileProposals[i]);
        }
        meeting.length_file_of_proposals += _newFileProposals.length;
        emit UpdateFileOfProposalMeeting(_meeting_id, _step);
    }

    function addFileMeetings(
        uint256 _meeting_id,
        FileOfMeetingData[] memory _newFileMeetings,
        uint256 _step
    ) internal {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        MeetingData storage meeting = meetings[_meeting_id];
        for (uint256 i = 0; i < _newFileMeetings.length; i++) {
            meeting.file_of_meetings.push(_newFileMeetings[i]);
        }
        meeting.length_file_of_meetings += _newFileMeetings.length;
        emit UpdateFileOfMeeting(_meeting_id, _step);
    }

    function updateMeeting(
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
    ) internal {
        require(meetings[_meeting_id].exsited, "err: meeting not exsited");
        MeetingData storage meeting = meetings[_meeting_id];

        meeting.title = _title;
        meeting.start_time = _start_time;
        meeting.end_time = _end_time;
        meeting.meeting_link = _meeting_link;
        meeting.company_id = _company_id;
        meeting.shareholders_totals = _shareholders_totals;
        meeting.shareholders_joined = _shareholders_joined;
        meeting.total_meeting_shares = _total_meeting_shares;
        meeting.joined_meeting_shares = _joined_meeting_shares;

        // Clear existing proposals and copy new ones
        // delete meeting.proposals;
        // delete meeting.participant_meetings;
        // delete meeting.file_of_proposals;
        // _updateProposals(meeting, _proposals);
        // _updateUsers(meeting, _participant_meetings);
        // _updateFiles(meeting, _file_of_proposals);
        emit UpdateMeeting(_meeting_id);
    }

    // For everyone to check if everything in data is correct
    function _getMeetingData(
        uint256 _meeting_id
    ) internal view returns (MeetingData memory) {
        return meetings[_meeting_id];
    }

    // For everyone to check if everything in data is correct
    function _getProposalByMeetingId(
        uint256 _meeting_id
    ) internal view returns (ProposalMeetingData[] memory) {
        return meetings[_meeting_id].proposals;
    }

    // For everyone to check if everything in data is correct
    function _getUserInfoByMeetingId(
        uint256 _meeting_id
    ) internal view returns (ParticipantMeetingData[] memory) {
        return meetings[_meeting_id].participant_meetings;
    }

    // For everyone to check if everything in data is correct
    function _getFileProposalByMeetingId(
        uint256 _meeting_id
    ) internal view returns (FileOfProposalData[] memory) {
        return meetings[_meeting_id].file_of_proposals;
    }

    function _getFileMeetingByMeetingId(
        uint256 _meeting_id
    ) internal view returns (FileOfMeetingData[] memory) {
        return meetings[_meeting_id].file_of_meetings;
    }

    // private function
    function _updateProposals(
        MeetingData storage _meet,
        ProposalMeetingData[] memory _proposals
    ) private {
        for (uint256 i = 0; i < _proposals.length; i++) {
            _meet.proposals.push(_proposals[i]);
        }
        _meet.length_proposals = _proposals.length;
    }

    function _updateUsers(
        MeetingData storage _meet,
        ParticipantMeetingData[] memory _participant_meetings
    ) private {
        for (uint256 i = 0; i < _participant_meetings.length; i++) {
            _meet.participant_meetings.push(_participant_meetings[i]);
        }
        _meet.length_participants = _participant_meetings.length;
    }

    function _updateFiles(
        MeetingData storage _meet,
        FileOfProposalData[] memory _file_of_proposals
    ) private {
        for (uint256 i = 0; i < _file_of_proposals.length; i++) {
            _meet.file_of_proposals.push(_file_of_proposals[i]);
        }
        _meet.length_file_of_proposals = _file_of_proposals.length;
    }
}
