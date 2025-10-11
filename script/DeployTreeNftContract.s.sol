// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/TreeNft.sol";
import "../src/token-contracts/CareToken.sol";
import "../src/token-contracts/PlanterToken.sol";
import "../src/token-contracts/LegacyToken.sol";

contract DeployTreeNft is Script {
    address public careTokenAddress;
    address public legacyTokenAddress;
    address public treeNftAddress;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with account:", deployer);
        console.log("Account balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);
        console.log("Step 1: Deploy ERC20 token contracts with deployer as temporary owner...");

        CareToken careToken = new CareToken(deployer);
        careTokenAddress = address(careToken);
        console.log("CareToken deployed at:", careTokenAddress);


        LegacyToken legacyToken = new LegacyToken(deployer);
        legacyTokenAddress = address(legacyToken);
        console.log("LegacyToken deployed at:", legacyTokenAddress);
        console.log("Step 2: Deploy TreeNft contract...");

        TreeNft treeNft = new TreeNft(careTokenAddress, legacyTokenAddress);
        treeNftAddress = address(treeNft);
        console.log("TreeNft deployed at:", treeNftAddress);
        console.log("Step 3: Transfer ownership to TreeNft contract...");
        careToken.transferOwnership(treeNftAddress);
        console.log("CareToken ownership transferred to TreeNft");
        legacyToken.transferOwnership(treeNftAddress);
        console.log("LegacyToken ownership transferred to TreeNft");

        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("CareToken:", careTokenAddress);
        console.log("LegacyToken:", legacyTokenAddress);
        console.log("TreeNft:", treeNftAddress);
        console.log("All token ownerships transferred to TreeNft!");
        console.log("========================\n");
        verifyDeployment();
    }

    function verifyDeployment() internal view {
        console.log("Verifying deployment...");
        TreeNft treeNft = TreeNft(treeNftAddress);

        require(address(treeNft.careTokenContract()) == careTokenAddress, "CareToken address mismatch");
        require(address(treeNft.legacyToken()) == legacyTokenAddress, "LegacyToken address mismatch");

        CareToken careToken = CareToken(careTokenAddress);
        if (careToken.owner() != treeNftAddress) revert OwnershipNotTransferred();

        LegacyToken legacyToken = LegacyToken(legacyTokenAddress);
        if (legacyToken.owner() != treeNftAddress) revert OwnershipNotTransferred();

        console.log("Deployment verification successful!");
    }
}
