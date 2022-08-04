// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Errors
error Marketplace__PriceLow();
error Marketplace__AlreadySold();
error Marketplace__InvalidItem(uint256 itemId);

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
    event Bought(
        uint256 itemId,
        address indexed nft,
        address indexed buyer,
        address indexed seller,
        uint256 tokenId,
        uint256 price
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

    function purchaseItem(uint256 _itemId) external payable nonReentrant {
        uint256 totalPrice = getTotalPrice(_itemId);
        Item memory item = s_items[_itemId];

        if (msg.value < totalPrice) revert Marketplace__PriceLow(); // paying less than item-price
        if (item.sold == true) revert Marketplace__AlreadySold(); // item already sold
        if (_itemId <= 0 || _itemId > itemCount)
            revert Marketplace__InvalidItem(_itemId); // given itemId to this func id invalid

        item.seller.transfer(item.price);
        i_feeAccount.transfer(totalPrice - item.price);

        item.sold = true;

        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        emit Bought(
            _itemId,
            address(item.nft),
            msg.sender,
            item.seller,
            item.tokenId,
            item.price
        );
    }

    // View & pure functions
    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return ((s_items[_itemId].price * (100 + i_feePercent)) / 100);
    }
}
