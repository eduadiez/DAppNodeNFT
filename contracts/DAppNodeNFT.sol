pragma solidity ^0.4.24;

import "./ERC721.sol";

/**
 * @title DAppNodeNFT
 */
contract DAppNodeNFT is ERC721 {

    constructor () public ERC721("TestNFT", "TestNFT"){}

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