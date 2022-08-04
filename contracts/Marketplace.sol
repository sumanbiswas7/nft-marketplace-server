// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error Marketplace__PriceLow();

contract Marketplace is ReentrancyGuard {
    struct Item {
        uint256 itemId;
        IERC721 nft;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }
    // State variables
    uint256 public immutable i_feePercent;
    address payable immutable i_feeAccount;
    uint256 public itemCount;

    // ItemId / itemCount -> Item
    mapping(uint256 => Item) public s_items;

    // Events
    event Offered(
        uint256 itemId,
        address indexed nft,
        uint256 price,
        uint256 tokenId,
        address indexed seller
    );

    constructor(uint256 _feePercent) {
        i_feePercent = _feePercent;
        i_feeAccount = payable(msg.sender);
    }

    function makeItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        if (_price <= 0) revert Marketplace__PriceLow();
        itemCount = itemCount + 1;
        _nft.transferFrom(msg.sender, address(this), _tokenId);

        s_items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );

        emit Offered(itemCount, address(_nft), _price, _tokenId, msg.sender);
    }
}
