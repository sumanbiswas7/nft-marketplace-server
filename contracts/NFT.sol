// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    uint256 public s_tokenId;

    constructor() ERC721("NFT", "nft") {}

    function mint(string memory _tokenURI) external returns (uint256) {
        s_tokenId = s_tokenId + 1;
        _safeMint(msg.sender, s_tokenId);
        _setTokenURI(s_tokenId, _tokenURI);
        return s_tokenId;
    }
}
