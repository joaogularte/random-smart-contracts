//SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.8.0;

contract BallotV2 {
    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }

    struct Proposal {
        uint voteCount;
    }

    address public chairperson;
    mapping (address => Voter) voters;
    Proposal [] proposals;

    enum State {Init, Regs, Vote, Done}
    State public state = State.Init;

    modifier validState(State reqState) {
        require(state == reqState);
        _;
    }

    modifier validNextState(State reqState) {
        require(reqState > state);
        _;
    }

    modifier validChairPerson() {
        require(msg.sender == chairperson);
        _;
    }

    constructor (uint numProposals) {
        chairperson =  msg.sender;
        voters[chairperson].weight = 2;
        for (uint prop = 0; prop < numProposals; prop ++)
            proposals.push(Proposal(0));
    }

    function changeState(State nextState) public validChairPerson() validNextState(nextState)  {
        state = nextState;
    }

    function register(address voter) public validState(State.Regs) validChairPerson()  {
        //Use if (condition) revert(); is equal to require(! condition);
        require(!voters[voter].voted);

        voters[voter].weight = 1;
        voters[voter].voted = false;
    }

    function vote(uint toProposal) public validState(State.Vote) {
        Voter memory voter = voters[msg.sender];
        require(!voter.voted);
        require(toProposal < proposals.length);

        voter.voted =  true;
        voter.vote = toProposal;
        proposals[toProposal].voteCount += voter.weight;
    }

    function reqWinner() public validState(State.Done) view returns (uint winningProposal) {
        uint winningVoteCount = 0;
        for (uint prop = 0; prop < proposals.length; prop++)
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
        assert (winningProposal >= 3);
    }
}
