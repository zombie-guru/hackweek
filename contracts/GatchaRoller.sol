// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./GatchaLoot.sol";

contract GatchaRoller {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
    mapping (address => uint) public balances;
    GatchaLoot private gatchaLoot;
    // list of IDs that still haven't been won yet. 0 IDs have already been won.
    uint[2] ownedGatchaLoot;

    // Constructor code is only run when the contract
    // is created
    constructor() {
        minter = msg.sender;
        gatchaLoot = new GatchaLoot();
        ownedGatchaLoot[0] = 1;
        gatchaLoot.mint(address(this), 1, 'https://my.url/0.png');
        ownedGatchaLoot[1] = 2;
        gatchaLoot.mint(address(this), 2, 'https://my.url/1.png');
    }
    
    function ownerOf(
        uint256 tokenId
    )
    external
    view
    returns (address)
    {
        return gatchaLoot.ownerOf(tokenId);
    }

    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function vendRollToken(address receiver, uint amount) public {
        require(msg.sender == minter);
        require(amount < 1e60);
        balances[receiver] += amount;
    }
    
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
            for (uint i=0; i<ownedGatchaLoot.length; i++) {
                uint loot = ownedGatchaLoot[i];
                if (loot == 0) {
                    continue;
                }
                gatchaLoot.transferFrom(address(this), msg.sender, loot);
                // mark as transfered
                ownedGatchaLoot[i] = 0;
                return;
            }
            // too bad, no loot left
        }
    }
}