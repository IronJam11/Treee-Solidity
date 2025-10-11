// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/forge-std/src/Test.sol";
import "../src/TreeNft.sol";
import "../src/token-contracts/CareToken.sol";
import "../src/token-contracts/LegacyToken.sol";
import "../src/token-contracts/PlanterToken.sol";
import "../src/utils/structs.sol";
import "../src/utils/errors.sol";

contract TreeNftVerificationTest is Test {
    TreeNft public treeNft;
    CareToken public careToken;
    LegacyToken public legacyToken;

    address public owner = address(0x1);
    address public planter = address(0x2);
    address public verifier1 = address(0x3);
    address public verifier2 = address(0x4);

    uint256 public constant LATITUDE = 45 * 1e6;
    uint256 public constant LONGITUDE = 90 * 1e6;
    string public constant SPECIES = "Oak";
    string public constant IMAGE_URI = "ipfs://image";
    string public constant QR_HASH = "ipfs://qr";
    string public constant METADATA = "metadata";
    string public constant GEOHASH = "geohash";
    uint256 public constant NUM_TREES = 10;

    function setUp() public {
        vm.startPrank(owner);
        careToken = new CareToken(owner);
        legacyToken = new LegacyToken(owner);
        treeNft = new TreeNft(address(careToken), address(legacyToken));
        careToken.transferOwnership(address(treeNft));
        legacyToken.transferOwnership(address(treeNft));
        vm.stopPrank();
    }

    function test_verifyTree() public {
        vm.prank(planter);
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        vm.prank(verifier1);
        string[] memory proofs = new string[](1);
        proofs[0] = "proof1";
        treeNft.verify(0, proofs, "verified");

        assertTrue(treeNft.isVerified(0, verifier1));
        
        address planterTokenAddr = treeNft.s_userToPlanterTokenAddress(verifier1);
        PlanterToken planterToken = PlanterToken(planterTokenAddr);
        assertEq(planterToken.balanceOf(planter), NUM_TREES);
    }

    function test_cannotVerifyOwnTree() public {
        vm.prank(planter);
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        vm.prank(planter);
        string[] memory proofs = new string[](1);
        proofs[0] = "proof1";
        vm.expectRevert(CannotVerifyOwnTree.selector);
        treeNft.verify(0, proofs, "verified");
    }

    function test_cannotVerifyTwice() public {
        vm.prank(planter);
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        vm.prank(verifier1);
        string[] memory proofs = new string[](1);
        proofs[0] = "proof1";
        treeNft.verify(0, proofs, "verified");

        vm.prank(verifier1);
        vm.expectRevert(AlreadyVerified.selector);
        treeNft.verify(0, proofs, "verified again");
    }

    function test_multipleVerifiers() public {
        vm.prank(planter);
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        vm.prank(verifier1);
        string[] memory proofs1 = new string[](1);
        proofs1[0] = "proof1";
        treeNft.verify(0, proofs1, "verified by v1");

        vm.prank(verifier2);
        string[] memory proofs2 = new string[](1);
        proofs2[0] = "proof2";
        treeNft.verify(0, proofs2, "verified by v2");

        assertTrue(treeNft.isVerified(0, verifier1));
        assertTrue(treeNft.isVerified(0, verifier2));

        address planterToken1 = treeNft.s_userToPlanterTokenAddress(verifier1);
        address planterToken2 = treeNft.s_userToPlanterTokenAddress(verifier2);
        
        assertEq(PlanterToken(planterToken1).balanceOf(planter), NUM_TREES);
        assertEq(PlanterToken(planterToken2).balanceOf(planter), NUM_TREES);
    }

    function test_removeVerification() public {
        vm.prank(planter);
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        vm.prank(verifier1);
        string[] memory proofs = new string[](1);
        proofs[0] = "proof1";
        treeNft.verify(0, proofs, "verified");

        vm.prank(planter);
        treeNft.removeVerification(0, verifier1);

        TreeNftVerification[] memory verifications = treeNft.getTreeNftVerifiers(0);
        assertEq(verifications.length, 0);
    }

    function test_onlyOwnerCanRemoveVerification() public {
        vm.prank(planter);
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        vm.prank(verifier1);
        string[] memory proofs = new string[](1);
        proofs[0] = "proof1";
        treeNft.verify(0, proofs, "verified");

        vm.prank(verifier2);
        vm.expectRevert(NotTreeOwner.selector);
        treeNft.removeVerification(0, verifier1);
    }

    function test_getTreeNftVerifiers() public {
        vm.prank(planter);
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        vm.prank(verifier1);
        string[] memory proofs1 = new string[](1);
        proofs1[0] = "proof1";
        treeNft.verify(0, proofs1, "verified by v1");

        vm.prank(verifier2);
        string[] memory proofs2 = new string[](1);
        proofs2[0] = "proof2";
        treeNft.verify(0, proofs2, "verified by v2");

        TreeNftVerification[] memory verifications = treeNft.getTreeNftVerifiers(0);
        assertEq(verifications.length, 2);
        assertEq(verifications[0].verifier, verifier1);
        assertEq(verifications[1].verifier, verifier2);
    }

    // THE FIXED VERSION OF THE FAILING TEST
    function test_getVerifiedTreesByUser() public {
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        
        // Mint first tree - SEPARATE transaction
        vm.prank(planter);
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);
        
        // Mint second tree - SEPARATE transaction with NEW prank
        vm.prank(planter);
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        string[] memory proofs = new string[](1);
        proofs[0] = "proof1";
        
        // Verify first tree - SEPARATE transaction
        vm.prank(verifier1);
        treeNft.verify(0, proofs, "verified tree 0");
        
        // Verify second tree - SEPARATE transaction with NEW prank
        vm.prank(verifier1);
        treeNft.verify(1, proofs, "verified tree 1");

        // Get verified trees - no prank needed for view function
        Tree[] memory verifiedTrees = treeNft.getVerifiedTreesByUser(verifier1);
        
        assertEq(verifiedTrees.length, 2);
        assertEq(verifiedTrees[0].id, 0);
        assertEq(verifiedTrees[1].id, 1);
    }

    function test_verificationIncreasesRevocationCounter() public {
        vm.prank(planter);
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        vm.prank(verifier1);
        treeNft.registerUserProfile("Verifier1", "ipfs://profile");

        vm.prank(verifier1);
        string[] memory proofs = new string[](1);
        proofs[0] = "proof1";
        treeNft.verify(0, proofs, "verified");

        vm.prank(planter);
        treeNft.removeVerification(0, verifier1);

        UserDetails memory userDetails = treeNft.getUserProfile(verifier1);
        assertEq(userDetails.verificationsRevoked, 1);
    }

    function test_cannotVerifyInvalidTree() public {
        vm.prank(verifier1);
        string[] memory proofs = new string[](1);
        proofs[0] = "proof1";
        vm.expectRevert(InvalidTreeID.selector);
        treeNft.verify(999, proofs, "verified");
    }

    function test_planterTokenCreatedOnFirstVerification() public {
        vm.prank(planter);
        string[] memory photos = new string[](1);
        photos[0] = "photo1";
        treeNft.mintNft(LATITUDE, LONGITUDE, SPECIES, IMAGE_URI, QR_HASH, METADATA, GEOHASH, photos, NUM_TREES);

        address planterTokenBefore = treeNft.s_userToPlanterTokenAddress(verifier1);
        assertEq(planterTokenBefore, address(0));

        vm.prank(verifier1);
        string[] memory proofs = new string[](1);
        proofs[0] = "proof1";
        treeNft.verify(0, proofs, "verified");

        address planterTokenAfter = treeNft.s_userToPlanterTokenAddress(verifier1);
        assertTrue(planterTokenAfter != address(0));
    }
}