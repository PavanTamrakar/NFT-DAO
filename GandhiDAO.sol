//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IGandhiDAO{
    function getPrice() external view returns (uint256);

    function available(uint256 _tokenId) external view returns (bool);

    function purchase(uint256 _tokenId) external payable;
}

interface IGandhiMoneyNFT {
    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

contract GandhiDAO is Ownable {

    enum Votes {
        yes,
        no
    }

    struct Proposal {
        uint256 nftTokenId;

        uint256 deadline;

        uint256 yesVotes;

        uint256 noVotes;

        bool executed;

        mapping(uint256 => bool) voters;

    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals;

    IDemoNftMarketplace nftMarketplace;
    
    IGandhiMoneyNFT GandhiMoneyNFT;

    constructor (address _nftMarketplace, address GandhiMoneyNFT) payable {
        nftMarketplace = IDemoNftMarketplace(_nftMarketplace);
        GandhiMoneyNFT = IGandhiMoneyNFT(_GandhiMoneyNFT);
    }

    modifier nftHolderOnly() {
        require(GandhiMoneyNFT.balanceOf(msg.sender) > 0, "Not a DAO Member");
        _;
    }

    modifier activeProposalOnly() {
        require(proposals[proposalId].deadline > block.timestam, "Proposal is Ended");
        _;
    }

    modifier notActiveProposalOnly() {
        require(proposals[proposalId].deadline <= block.timestam, "Proposal not Ended");
        require(proposals[proposalId].executed == false, "Proposal alreaady Executed");
        _;
    }

    function createProposal(uint256 _nftTokenId) external nftHolderOnly returns (uint256) {
        require(nftMarketplace.available(_nftTokenId), "Not for sale");

        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        proposal.deadline = block.timestamp + 2 days;

        numProposals ++;

        numProposals -1;
    }
    
    function voteOnProposal(uint256 proposalId, Vote vote) external nftHolderOnly activeProposalOnly(proposalId){
        Proposal storage proposal = proposals[proposalId];

        uint256 voterNftBalance = GandhiMoneyNFT.balanceOf(msg.sender);

        uint256 numVotes;

        for (i = 0; i < voterNftBalance; ++i){
            uint256 tokenId = GandhiMoneyNFT.balanceOfOwnerByIndex(msg.sender, i);
            if (proposal.voters[tokenId] == false){
                numVotes++;
                proposal.voters[tokenId] = true;
            }
        }

        require(numVotes > 0, "Already Voted!");

        if (vote == Vote.yes){
            proposal.yesVotes += numVotes;
        }else{
            proposal.noVotes += numVotes;
        }
    }

    function executeProposal(uint256 proposalId) external nftHolderOnly inActiveProposalOnly(proposalId){
        Proposal storage proposal = proposals[proposalId];

        if (proposal.yesVotes > proposal.noVotes){
            uint256 nftPrice = nftMarketplace.getPrice();
            require(address(this).balance >= nftPrice, "Not Enough Funds");
            nftMarketPlace.purchase{vakue: nftPrice}(proposal.nftTokenId);
        }

        proposal.executed = true;
    }
    
    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    fallback() external payable {}

}
