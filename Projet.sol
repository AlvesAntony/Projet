pragma solidity ^0.7.0 ;

// SPDX-License-Identifier: GPL-3.0

contract Election {
    struct Candidate {
        string name;
        uint voteCount;
    }

    struct Voter {
        uint weight;
        bool voted;
        uint vote;
        address delegate;
    }
    
    address public owner;
    string public election;
    
    mapping(address=>Voter) public electeurs;
    Candidate[] public candidats;
    uint public total_Votes;
    
    modifier ownerOnly() {
        require(msg.sender == owner);
    _;
    }
    
    constructor (string memory _name) public {
        owner = msg.sender;
        electeurs[owner].weight = 1;
    }
    
    function ajout_candidat (string memory _name) ownerOnly public {
        candidats.push(Candidate(_name, 0));
    }
    
    function Nb_candidat() public view returns(uint) {
        return candidats.length ;
    }
    
    function giveRightToVote(address voter) public {
        require(
            msg.sender == owner,
            "Only chairperson can give right to vote."
        );
        require(
            !electeurs[voter].voted,
            "The voter already voted."
        );
        require(electeurs[voter].weight == 0);
        electeurs[voter].weight = 1;
    }
    
    function delegate(address to) public {
        Voter storage sender = electeurs[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (electeurs[to].delegate != address(0)) {
            to = electeurs[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = electeurs[to];
        delegate_.weight += sender.weight;
        sender.weight -= 1;
    }
    
    
    function vote(uint Candidate) public {
        Voter storage sender = electeurs[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        //require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = Candidate;
        sender.weight -= 1;

        // If 'Candidate' is out of the range of the array,
        // this will throw automatically and revert all changes.
        candidats[Candidate].voteCount += sender.weight;
    }
    
    function winningCandidate() public view
            returns (uint winningCandidate_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < candidats.length; p++) {
            if (candidats[p].voteCount > winningVoteCount) {
                winningVoteCount = candidats[p].voteCount;
                winningCandidate_ = p;
            }
        }
    }
    
    function winnerName() public view
            returns (string memory winnerName)
    {
        winnerName = candidats[winningCandidate()].name;
    }
    
    function Fin() ownerOnly public {
        selfdestruct(msg.sender);
    }
}