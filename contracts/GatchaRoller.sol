// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.5.6;

import "./GatchaLoot.sol";

contract GatchaRoller {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
    mapping (address => uint) public balances;
    GatchaLoot public gatchaLoot;

    // nfts already transfered.
    mapping (uint => bool) public nftsTransfered;
    // number of available ids
    uint numberOfIds;
    // addresses and the twitch users they belong to
    mapping (address => string) public addressToTwitchUser;

    // Constructor code is only run when the contract
    // is created
    constructor() public {
        minter = msg.sender;
        gatchaLoot = new GatchaLoot();
        numberOfIds = 2;
        gatchaLoot.mint(address(this), 0, 'https://my.url/0.png');
        gatchaLoot.mint(address(this), 1, 'https://my.url/1.png');
    }

    // get the twitch owner of an NFT
    function twitchOwnerOf(
        uint256 tokenId
    )
    external
    view
    returns (string memory)
    {
        address owner = gatchaLoot.ownerOf(tokenId);
        if (owner == minter) {
            return "";
        }
        return addressToTwitchUser[owner];
    }

    // associate a Twitch user with this address
    function associateTwitchUser(string memory userName) public {
        addressToTwitchUser[msg.sender] = userName;
    }

    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function vendRollToken(address receiver, uint amount) public {
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
            ) % 2
        );
        if (rand == 0) {
            // transfer ownership of the NFT
            for (uint i=0; i<numberOfIds; i++) {
                if (nftsTransfered[i]) {
                    continue;
                }
                gatchaLoot.transferFrom(address(this), msg.sender, i);
                // mark as transfered
                nftsTransfered[i] = true;
                return;
            }
            // too bad, no loot left
        }
    }
}
