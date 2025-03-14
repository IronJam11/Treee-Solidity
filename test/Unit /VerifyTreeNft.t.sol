// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/TreeeNft.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TreeNftTest is Test {
    TreeNft public treeNft;
    address user2 = address(0x537C8f3d3E18dF5517a58B3fB9D9143697996802);

    function setUp() public {
        treeNft = new TreeNft();
    }

    function testVerifyTree() public {
        vm.prank(user2);
        treeNft.mintNft(123456, 654321, "Oak", "");
        assertEq(treeNft.ownerOf(0), user2);
        vm.prank(user2);
        treeNft.verify(0);
        bool isVerified = treeNft.isVerified(0, user2);
        assertEq(isVerified, true);
        string[] memory allNFTs = treeNft.getAllNFTs();
        string memory nftJson = allNFTs[0];
        bool containsVerifier = _stringContains(nftJson, _toHexString(user2));
        assertTrue(containsVerifier, "Verifier address should be present in getAllNFTs()");
    }

    function _stringContains(string memory main, string memory sub) internal pure returns (bool) {
        return bytes(main).length > 0 && bytes(sub).length > 0 && (bytes(main).length >= bytes(sub).length)
            && _indexOf(main, sub) != -1;
    }

    function _toHexString(address addr) internal pure returns (string memory) {
        return Strings.toHexString(uint256(uint160(addr)), 20);
    }

    function _indexOf(string memory main, string memory sub) internal pure returns (int256) {
        bytes memory mainBytes = bytes(main);
        bytes memory subBytes = bytes(sub);

        if (subBytes.length > mainBytes.length) {
            return -1;
        }

        for (uint256 i = 0; i <= mainBytes.length - subBytes.length; i++) {
            bool matchFound = true;
            for (uint256 j = 0; j < subBytes.length; j++) {
                if (mainBytes[i + j] != subBytes[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) {
                return int256(i);
            }
        }
        return -1;
    }
}
