pragma solidity >=0.4.22 <0.7.0;

contract SimpleAuction {
    address payable public beneficiary;
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    /// Give biddingTime and beneficiary address
    constructor (uint _biddingTime, address payable _beneficiary) public {
        beneficiary = _beneficiary;
        auctionEndTime = now + _biddingTime;
    }

    function bid() public payable {
        require(now <= auctionEndTime, "Auction aleady ended");

        require(msg.value > highestBid, "There is already a higher bid");

        if(highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if(amount > 0) {
            pendingReturns[msg.sender] = 0;

            if(!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        require(now >= auctionEndTime, "Auction not yet ended");
        require(!ended, "Auction has already ended");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
}