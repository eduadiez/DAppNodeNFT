pragma solidity ^0.4.24;

import "./ERC721.sol";
import "@aragon/os/contracts/apps/AragonApp.sol";

/**
 * @title AragonNFT
 */
contract AragonNFT is ERC721, AragonApp {
    function initialize(string name, string symbol) onlyInit {
        configureToken(name, symbol);

        initialized();
    }

    // TODO: add roles
    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public {
        _burn(_ownerOf(tokenId), tokenId);
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _tokensOfOwner(owner);
    }

    function setTokenURI(uint256 tokenId, string uri) public {
        _setTokenURI(tokenId, uri);
    }

    function removeTokenFrom(address from, uint256 tokenId) public {
        _removeTokenFrom(from, tokenId);
    }
}