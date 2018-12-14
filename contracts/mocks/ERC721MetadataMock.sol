pragma solidity ^0.4.24;

import "../ERC721Metadata.sol";
import "../ERC721Enumerable.sol";


/**
 * @title ERC721FullMock
 * This mock just provides public functions for setting metadata URI, getting all tokens of an owner,
 * checking token existence, removal of a token from an address 
 */
contract ERC721MetadataMock is ERC721Metadata, ERC721Enumerable {

    constructor (string name, string symbol) public ERC721Metadata(name, symbol){}

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
