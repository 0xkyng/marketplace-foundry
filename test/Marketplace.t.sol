// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Marketplace} from "../src/Marketplace.sol";
import "../src/ERC721Mock.sol";
import "./Helpers.sol";

contract MarketPlaceTest is Helpers {
    Marketplace mPlace;
    CHIXNFT chix;

    uint256 currentCatId;

    address userA;
    address userB;

    uint256 privKeyA;
    uint256 privKeyB;

    Marketplace.Catalogue c;

    function setUp() public {
        mPlace = new Marketplace();
        chix = new CHIXNFT();

        (userA, privKeyA) = mkaddr("USERA");
        (userB, privKeyB) = mkaddr("USERB");

        c = Marketplace.Catalogue({
            nftAddress: address(chix),
            tokenId: 1,
            price: 1 ether,
            signature: bytes(""),
            deadline: 0,
            creator: address(0),
            active: false
        });

        // mint NFT
        chix.mint(userA, 1);
    }

    function testOnlyOwnerCanCreateCatalogue() public {
        changeSigner(userB);

        vm.expectRevert(bytes("NOt the owner"));
        mPlace.createCatalogue(c);
    }

    function testNonApprovedNFT() public {
        changeSigner(userA);
        vm.expectRevert(bytes("You don't have approval to sell this nft"));
        mPlace.createCatalogue(c);
    }


    function testPriceTooLow() public {
        changeSigner(userA);
        chix.setApprovalForAll(address(mPlace), true);
        c.price = 0;
        vm.expectRevert(bytes("Low price"));
        mPlace.createCatalogue(c);
    }


    function testMinDuration() public {
        changeSigner(userA);
        chix.setApprovalForAll(address(mPlace), true);
        c.deadline = uint88(block.timestamp + 59 minutes);
        vm.expectRevert(bytes("Deadline too short"));
        mPlace.createCatalogue(c);
    }

    function testValidSig() public {
        changeSigner(userA);
        chix.setApprovalForAll(address(mPlace), true);
        c.deadline = uint88(block.timestamp + 90 minutes);
        c.signature = createSig(
            c.nftAddress,
            c.tokenId,
            c.price,
            c.deadline,
            c.creator,
            privKeyB
        );
        vm.expectRevert(bytes("Invalid signsture"));
        mPlace.createCatalogue(c);
    }

    // // EDIT LISTING
    // function testEditNonValidListing() public {
    //     changeSigner(userA);
    //     vm.expectRevert(Marketplace.ListingNotExistent.selector);
    //     mPlace.editListing(1, 0, false);
    // }

    // function testEditListingNotOwner() public {
    //     changeSigner(userA);
    //     chix.setApprovalForAll(address(mPlace), true);
    //     c.deadline = uint88(block.timestamp + 120 minutes);
    //     c.sig = createSig(
    //         c.token,
    //         c.tokenId,
    //         c.price,
    //         c.deadline,
    //         c.creator,
    //         privKeyA
    //     );
    //     // vm.expectRevert(Marketplace.ListingNotExistent.selector);
    //     uint256 cId = mPlace.createListing(c);

    //     changeSigner(userB);
    //     vm.expectRevert(Marketplace.NotOwner.selector);
    //     mPlace.editListing(cId, 0, false);
    // }

    // function testEditListing() public {
    //     changeSigner(userA);
    //     chix.setApprovalForAll(address(mPlace), true);
    //     c.deadline = uint88(block.timestamp + 120 minutes);
    //     c.sig = createSig(
    //         c.token,
    //         c.tokenId,
    //         c.price,
    //         c.deadline,
    //         c.creator,
    //         privKeyA
    //     );
    //     uint256 cId = mPlace.createListing(c);
    //     mPlace.editListing(cId, 0.01 ether, false);

    //     Marketplace.Catalogue memory t = mPlace.getListing(cId);
    //     assertEq(t.price, 0.01 ether);
    //     assertEq(t.active, false);
    // }

    // // EXECUTE LISTING
    // function testExecuteNonValidListing() public {
    //     changeSigner(userA);
    //     vm.expectRevert(Marketplace.ListingNotExistent.selector);
    //     mPlace.executeListing(1);
    // }

    // function testExecuteExpiredListing() public {
    //     changeSigner(userA);
    //     chix.setApprovalForAll(address(mPlace), true);
    // }

    // function testExecuteListingNotActive() public {
    //     changeSigner(userA);
    //     chix.setApprovalForAll(address(mPlace), true);
    //     c.deadline = uint88(block.timestamp + 120 minutes);
    //     c.sig = createSig(
    //         c.token,
    //         c.tokenId,
    //         c.price,
    //         c.deadline,
    //         c.creator,
    //         privKeyA
    //     );
    //     uint256 lId = mPlace.createListing(c);
    //     mPlace.editListing(lId, 0.01 ether, false);
    //     changeSigner(userB);
    //     vm.expectRevert(Marketplace.ListingNotActive.selector);
    //     mPlace.executeListing(lId);
    // }

    // function testExecutePriceNotMet() public {
    //     changeSigner(userA);
    //     chix.setApprovalForAll(address(mPlace), true);
    //     c.deadline = uint88(block.timestamp + 120 minutes);
    //     c.sig = createSig(
    //         c.token,
    //         c.tokenId,
    //         c.price,
    //         c.deadline,
    //         c.creator,
    //         privKeyA
    //     );
    //     uint256 cId = mPlace.createListing(c);
    //     changeSigner(userB);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(
    //             Marketplace.PriceNotMet.selector,
    //             c.price - 0.9 ether
    //         )
    //     );
    //     mPlace.executeListing{value: 0.9 ether}(cId);
    // }

    // function testExecutePriceMismatch() public {
    //     changeSigner(userA);
    //     chix.setApprovalForAll(address(mPlace), true);
    //     c.deadline = uint88(block.timestamp + 120 minutes);
    //     c.sig = createSig(
    //         c.token,
    //         c.tokenId,
    //         c.price,
    //         c.deadline,
    //         c.creator,
    //         privKeyA
    //     );
    //     uint256 cId = mPlace.createListing(c);
    //     changeSigner(userB);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(Marketplace.PriceMismatch.selector, c.price)
    //     );
    //     mPlace.executeListing{value: 1.1 ether}(cId);
    // }

    // function testExecute() public {
    //     changeSigner(userA);
    //     chix.setApprovalForAll(address(mPlace), true);
    //     c.deadline = uint88(block.timestamp + 120 minutes);
    //     // l.price = 1 ether;
    //     c.sig = createSig(
    //         c.token,
    //         c.tokenId,
    //         c.price,
    //         c.deadline,
    //         c.creator,
    //         privKeyA
    //     );
    //     uint256 cId = mPlace.createListing(c);
    //     changeSigner(userB);
    //     uint256 userABalanceBefore = userA.balance;

    //     mPlace.executeListing{value: c.price}(cId);

    //     uint256 userABalanceAfter = userA.balance;

    //     Marketplace.Catalogue memory t = mPlace.getListing(cId);
    //     assertEq(t.price, 1 ether);
    //     assertEq(t.active, false);

    //     assertEq(t.active, false);
    //     assertEq(ERC721(c.token).ownerOf(c.tokenId), userB);
    //     assertEq(userABalanceAfter, userABalanceBefore + c.price);
    // }
}
