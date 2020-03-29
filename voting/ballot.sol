pragma solidity >=0.4.22 <0.7.0;

contract Ballot {

    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;


    /// Give a proposal names array
    constructor(bytes32[] memory proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for(uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }

    }

    function giveRightToVote(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can give the right to vote");

        require(!voters[voter].voted, "the voter has already voted");

        require(voters[voter].weight == 0, "the person doesnot already have rights");

        voters[voter].weight = 1;
    }

    function delegate(address to) public{

        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "you have already voted");
        require(to != msg.sender, "self-delegation is not allowed");

        while(voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            require(to != msg.sender, "self-delegation is not allowed");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];

        if(delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "has no right to vote");
        require(!sender.voted, "already voted");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint winningProposal_){
        uint winningVoteCount = 0;

        for(uint i = 0; i < proposals.length; i++) {
            if(proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }

    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }

}