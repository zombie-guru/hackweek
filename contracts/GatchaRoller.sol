// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.5.6;

import "./GatchaLoot.sol";

contract GatchaRoller {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
    mapping(address => uint256) public balances;
    GatchaLoot public gatchaLoot;

    // nfts already transfered.
    mapping(uint256 => bool) public nftsTransfered;
    // number of available ids
    uint256 numberOfIds;
    // addresses and the twitch users they belong to
    mapping(address => string) public addressToTwitchUser;

    event GatchaWin(address winner, uint256 id);

    // Constructor code is only run when the contract
    // is created
    constructor() public {
        minter = msg.sender;
        gatchaLoot = new GatchaLoot();
        numberOfIds = 11;
        gatchaLoot.mint(
            address(this),
            0,
            "https://d225uztlf78d4e.cloudfront.net/anselnft1.png"
        );
        gatchaLoot.mint(
            address(this),
            1,
            "https://d225uztlf78d4e.cloudfront.net/bachnft1.png"
        );
        gatchaLoot.mint(
            address(this),
            2,
            "https://d225uztlf78d4e.cloudfront.net/catnft1.png"
        );
        gatchaLoot.mint(
            address(this),
            3,
            "https://d225uztlf78d4e.cloudfront.net/catnft2.png"
        );
        gatchaLoot.mint(
            address(this),
            4,
            "https://d225uztlf78d4e.cloudfront.net/dognft1.png"
        );
        gatchaLoot.mint(
            address(this),
            5,
            "https://d225uztlf78d4e.cloudfront.net/dognft2.png"
        );
        gatchaLoot.mint(
            address(this),
            6,
            "https://d225uztlf78d4e.cloudfront.net/dognft3.png"
        );
        gatchaLoot.mint(
            address(this),
            7,
            "https://d225uztlf78d4e.cloudfront.net/emmettnft2.jpg"
        );
        gatchaLoot.mint(
            address(this),
            8,
            "https://d225uztlf78d4e.cloudfront.net/emmettslacknft.png"
        );
        gatchaLoot.mint(
            address(this),
            9,
            "https://d225uztlf78d4e.cloudfront.net/mattnft1.jpg"
        );
        gatchaLoot.mint(
            address(this),
            10,
            "https://d225uztlf78d4e.cloudfront.net/tomnft5.jpg"
        );
    }

    // get the twitch owner of an NFT
    function twitchOwnerOf(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        address owner = gatchaLoot.ownerOf(tokenId);
        return addressToTwitchUser[owner];
    }

    function getTokenUri(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        return gatchaLoot.tokenURI(tokenId);
    }

    // associate a Twitch user with this address
    function associateTwitchUser(string memory userName) public {
        addressToTwitchUser[msg.sender] = userName;
    }

    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function vendRollToken(address receiver, uint256 amount) public {
        require(msg.sender == minter);
        require(amount < 1e60);
        balances[receiver] += amount;
    }

    // send a roll token to roll for an NFT
    function roll() public {
        require(balances[msg.sender] > 1, "you must have at least 1 token");
        balances[msg.sender] -= 1;

        bytes32 bHash = blockhash(block.number - 1);
        uint8 rand = uint8(
            uint256(
                keccak256(abi.encodePacked(block.timestamp, bHash, uint256(14)))
            ) % 1
        );
        if (rand == 0) {
            // transfer ownership of the NFT
            for (uint256 i = 0; i < numberOfIds; i++) {
                if (nftsTransfered[i]) {
                    continue;
                }
                gatchaLoot.transferFrom(address(this), msg.sender, i);
                // mark as transfered
                nftsTransfered[i] = true;
                emit GatchaWin(msg.sender, i);
                return;
            }
            // too bad, no loot left
        }
    }
}
