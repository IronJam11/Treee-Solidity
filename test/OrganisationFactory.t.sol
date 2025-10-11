// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";

import "../src/OrganisationFactory.sol";
import "../src/Organisation.sol";
import "../src/utils/structs.sol";
import "../src/utils/errors.sol";
import "../src/TreeNft.sol";

import "../src/token-contracts/CareToken.sol";
import "../src/token-contracts/PlanterToken.sol";
import "../src/token-contracts/LegacyToken.sol";

contract OrganisationFactoryTest is Test {
    OrganisationFactory private factory;
    TreeNft private treeNft;
    CareToken public careToken;
    LegacyToken public legacyToken;

    address private owner = address(0x1);
    address private user1 = address(0x2);
    address private user2 = address(0x3);
    address private user3 = address(0x4);
    address private user4 = address(0x5);

    string constant NAME1 = "Test Organisation";
    string constant DESCRIPTION1 = "This is a test organisation.";
    string constant PHOTO_IPFS_HASH1 = "QmTestPhotoHash";
    string constant NAME2 = "Test Organisation";
    string constant DESCRIPTION2 = "This is a test organisation.";
    string constant PHOTO_IPFS_HASH2 = "QmTestPhotoHash";

    function setUp() public {
        vm.startPrank(owner);

        careToken = new CareToken(owner);
        legacyToken = new LegacyToken(owner);

        treeNft = new TreeNft(address(careToken), address(legacyToken));

        careToken.transferOwnership(address(treeNft));
        legacyToken.transferOwnership(address(treeNft));

        vm.stopPrank();

        assertEq(careToken.owner(), address(treeNft));
        assertEq(legacyToken.owner(), address(treeNft));

        assertEq(address(treeNft.careTokenContract()), address(careToken));
        assertEq(address(treeNft.legacyToken()), address(legacyToken));

        vm.startPrank(owner);
        factory = new OrganisationFactory(address(treeNft));
        vm.stopPrank();
    }

    function test_Constructor() public view {
        // This test checks if the constructor initializes the factory correctly by verifying the owner, treeNFTContract, and organisation count.

        assertEq(factory.owner(), owner);
        assertEq(factory.treeNFTContract(), address(treeNft));
        assertEq(factory.getOrganisationCount(), 0);
    }

    function test_CreateOrganisation() public {
        // This test checks if the createOrganisation function works correctly by creating an organisation and verifying its details.

        vm.prank(user1);
        (uint256 orgId, address orgAddress) = factory.createOrganisation(NAME1, DESCRIPTION1, PHOTO_IPFS_HASH1);
        assertEq(orgId, 0);
        assertEq(factory.getOrganisationCount(), 1);
        (
            address organizationAddress,
            string memory name,
            string memory description,
            string memory photoIpfsHash,
            address[] memory owners,
            address[] memory members,
            uint256 timeOfCreation
        ) = factory.getOrganisationInfo(orgAddress);
        assert(organizationAddress == orgAddress);
        assertEq(name, NAME1);
        assertEq(description, DESCRIPTION1);
        assertEq(photoIpfsHash, PHOTO_IPFS_HASH1);
        assertEq(owners[0], user1);
        assertEq(members.length, 1);
        assertEq(timeOfCreation, block.timestamp);
    }

    function test_getMyOrganisations() public {
        // This test checks if the getMyOrganisations function returns the correct organisation details for a user.

        vm.prank(user1);
        factory.createOrganisation(NAME1, DESCRIPTION1, PHOTO_IPFS_HASH1);
        vm.stopPrank();
        vm.prank(user2);
        factory.createOrganisation(NAME2, DESCRIPTION2, PHOTO_IPFS_HASH2);
        vm.stopPrank();

        vm.startPrank(user1);
        address[] memory user1Orgs = factory.getMyOrganisations();
        vm.stopPrank();
        vm.startPrank(user2);
        address[] memory user2Orgs = factory.getMyOrganisations();
        vm.stopPrank();

        assertEq(user1Orgs.length, 1);
        assertEq(user2Orgs.length, 1);
    }

    function test_getAllOrganisations() public {
        // This test checks if the factory can return all organisations correctly.

        vm.prank(user1);
        factory.createOrganisation(NAME1, DESCRIPTION1, PHOTO_IPFS_HASH1);
        vm.stopPrank();
        vm.prank(user2);
        factory.createOrganisation(NAME2, DESCRIPTION2, PHOTO_IPFS_HASH2);
        vm.stopPrank();

        OrganisationDetails[] memory orgs = factory.getAllOrganisationDetails();
        assertEq(orgs.length, 2);
        assertEq(orgs[0].name, NAME1);
        assertEq(orgs[0].description, DESCRIPTION1);
        assertEq(orgs[0].photoIpfsHash, PHOTO_IPFS_HASH1);
        assertEq(orgs[0].ownerCount, 1);
        assertEq(orgs[0].memberCount, 1);
        assertEq(orgs[1].name, NAME2);
        assertEq(orgs[1].description, DESCRIPTION2);
        assertEq(orgs[1].photoIpfsHash, PHOTO_IPFS_HASH2);
        assertEq(orgs[1].ownerCount, 1);
        assertEq(orgs[1].memberCount, 1);
    }

    function test_getAllOrganisationIDs() public {
        // This test checks if the factory can return all organisation IDs correctly.

        vm.prank(user1);
        factory.createOrganisation(NAME1, DESCRIPTION1, PHOTO_IPFS_HASH1);
        vm.stopPrank();
        vm.prank(user2);
        factory.createOrganisation(NAME2, DESCRIPTION2, PHOTO_IPFS_HASH2);
        vm.stopPrank();

        address[] memory orgAddresses = factory.getAllOrganisations();
        assertEq(orgAddresses.length, 2);
    }
}
