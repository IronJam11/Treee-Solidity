// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

struct OrganisationDetails {
    address contractAddress;
    string name;
    string description;
    string organisationPhoto;
    address[] owners;
    address[] members;
    uint256 ownerCount;
    uint256 memberCount;
    bool isActive;
    uint256 timeOfCreation;
}

struct TreeNftVerification {
    address verifier;
    uint256 timestamp;
    string[] proofHashes;
    string description;
    bool isHidden;
    uint256 treeNftId;
    address verifierPlanterTokenAddress;
}

struct VerificationDetails {
    address verifier;
    uint256 timestamp;
    string[] proofHashes;
    string description;
    bool isHidden;
    uint256 numberOfTrees;
    address verifierPlanterTokenAddress;
}

struct OrganisationVerificationRequest {
    uint256 id;
    address initialMember;
    address organisationContract;
    uint256 status;
    string description;
    uint256 timestamp;
    string[] proofHashes;
    uint256 treeNftId;
}

struct User {
    address userAddress;
    string profilePhoto;
    string name;
    uint256 dateJoined;
    uint256 verificationsRevoked;
    uint256 reportedSpam;
}

struct UserDetails {
    address userAddress;
    string profilePhoto;
    string name;
    uint256 dateJoined;
    uint256 verificationsRevoked;
    uint256 reportedSpam;
    uint256 legacyTokens;
    uint256 careTokens;
}

struct Tree {
    uint256 id;
    uint256 latitude;
    uint256 longitude;
    uint256 planting;
    uint256 death;
    string species;
    string imageUri;
    string qrPhoto;
    string metadata;
    string[] photos;
    string geoHash;
    address[] ancestors;
    uint256 lastCareTimestamp;
    uint256 careCount;
    uint256 numberOfTrees;
}

struct TreePlantingProposal {
    uint256 id;
    uint256 latitude;
    uint256 longitude;
    string species;
    string imageUri;
    string qrPhoto;
    string[] photos;
    string geoHash;
    string metadata;
    uint256 status;
    uint256 numberOfTrees;
}
