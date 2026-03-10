# Minimalist NFT Marketplace

A high-performance, single-file NFT marketplace contract designed for fixed-price sales. This implementation focuses on security and "Pull Payment" patterns to prevent common reentrancy and DOS attacks.

### Key Features
* **Fixed Price Listings:** Users can list any ERC-721 token for a specific price.
* **Escrow-less Trading:** Tokens remain in the user's wallet until the moment of sale (requires approval).
* **Security:** Uses `ReentrancyGuard` and atomic transactions to ensure safe swaps.
* **Events:** Fully indexed events for easy frontend integration and subgraph indexing.

### Quick Start
1. Deploy `Marketplace.sol`.
2. To list an NFT, call `listToken(nftAddress, tokenId, price)`.
3. To buy, call `buyToken(listingId)` and send the required ETH.

### License
MIT
