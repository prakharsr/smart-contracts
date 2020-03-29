pragma solidity >=0.4.22 <0.7.0;

contract Auction {

    struct Item {
        uint itemId;
        uint[] itemTokens;
    }

    struct Person {
        uint remainingTokens;
        uint personId;
        address addr;
    }
    mapping(address => Person) tokenDetails;
    Person[4] bidders;
    Item[3] public items;
    address[3] public winners;
    address public beneficiary;

    uint bidderCount=0;

    constructor() public payable{

        beneficiary = msg.sender;

        uint[] memory emptyArray;
        items[0] = Item({itemId:0,itemTokens:emptyArray});
        items[1] = Item({itemId:1, itemTokens:emptyArray});
        items[2] = Item({itemId:2, itemTokens:emptyArray});
    }

    modifier onlyOwnerCanReveal() {
        require(msg.sender==beneficiary, "Only owner can reveal"); _;}

    function register() public payable{
        bidders[bidderCount].personId = bidderCount;
        bidders[bidderCount].addr = msg.sender;
        bidders[bidderCount].remainingTokens = 5;
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;
    }
    function bid(uint _itemId, uint _count) public payable{
        if(tokenDetails[msg.sender].remainingTokens < _count || _itemId>2 ) revert("not enough remaining tokens, enter a lesser value");
        if(tokenDetails[msg.sender].remainingTokens == 0 ) revert("not enough remaining tokens");
        if(_itemId>2 ) revert("itemId invalid");
        tokenDetails[msg.sender].remainingTokens -= _count;
        bidders[tokenDetails[msg.sender].personId].remainingTokens = tokenDetails[msg.sender].remainingTokens;
        Item storage bidItem = items[_itemId];
        for(uint i = 0; i < _count; i++) {
        bidItem.itemTokens.push(tokenDetails[msg.sender].personId);
        }
    }
    function revealWinners() public onlyOwnerCanReveal {

        for (uint id = 0; id < 3; id++) {
        Item storage currentItem = items[id];
        if(currentItem.itemTokens.length != 0){
            uint randomIndex = (block.number / currentItem.itemTokens.length) % currentItem.itemTokens.length;
            uint winnerId = currentItem.itemTokens[randomIndex];
            winners[id] = bidders[winnerId].addr;
            }
        }
    }

    function getPersonDetails(uint id) public view returns(uint,uint,address){
        return (bidders[id].remainingTokens,bidders[id].personId,bidders[id].addr);
    }
}