// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title MinimalMarketplace
 * @dev A gas-optimized marketplace for ERC721 tokens.
 */
contract MinimalMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    uint256 public listingCount;
    mapping(uint256 => Listing) public listings;

    event TokenListed(uint256 indexed listingId, address indexed seller, address nft, uint256 tokenId, uint256 price);
    event TokenSold(uint256 indexed listingId, address indexed buyer, uint256 price);
    event ListingCanceled(uint256 indexed listingId);

    /**
     * @notice List an NFT for sale
     */
    function listToken(address _nftAddress, uint256 _tokenId, uint256 _price) external {
        require(_price > 0, "Price must be greater than zero");
        IERC721 nft = IERC721(_nftAddress);
        require(nft.ownerOf(_tokenId) == msg.sender, "Not the owner");
        require(nft.isApprovedForAll(msg.sender, address(this)), "Marketplace not approved");

        listingCount++;
        listings[listingCount] = Listing(msg.sender, _nftAddress, _tokenId, _price, true);

        emit TokenListed(listingCount, msg.sender, _nftAddress, _tokenId, _price);
    }

    /**
     * @notice Purchase a listed NFT
     */
    function buyToken(uint256 _listingId) external payable nonReentrant {
        Listing storage listing = listings[_listingId];
        require(listing.active, "Listing not active");
        require(msg.value >= listing.price, "Insufficient payment");

        listing.active = false;
        
        IERC721(listing.nftAddress).safeTransferFrom(listing.seller, msg.sender, listing.tokenId);
        
        (bool success, ) = payable(listing.seller).call{value: listing.price}("");
        require(success, "Transfer to seller failed");

        emit TokenSold(_listingId, msg.sender, listing.price);
    }

    /**
     * @notice Cancel an existing listing
     */
    function cancelListing(uint256 _listingId) external {
        Listing storage listing = listings[_listingId];
        require(msg.sender == listing.seller, "Not the seller");
        require(listing.active, "Listing already inactive");

        listing.active = false;
        emit ListingCanceled(_listingId);
    }
}
