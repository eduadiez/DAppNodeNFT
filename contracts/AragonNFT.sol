pragma solidity ^0.4.24;

import "./ERC721.sol";
import "@aragon/os/contracts/apps/AragonApp.sol";

/**
 * @title AragonNFT
 * @author Eduardo Antuña <eduadiez@gmail.com>
 * @dev The main goal of this token contract is to make it easy for anyone to install
 * this AragonApp to get an NFT Token that can be handled from a DAO. This will be the 
 * NFT used by the DAppNode association.
 * It's based on the ERC721 standard http://ERC721.org https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 * and the awesome smartcontracts and tools developed by https://github.com/OpenZeppelin/openzeppelin-solidity 
 * as well as those developed by Aragon https://github.com/aragon
 */
contract AragonNFT is ERC721, AragonApp {

    /// ACL
    bytes32 constant public MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 constant public BURN_ROLE = keccak256("BURN_ROLE");

    /**
     * @dev Function to initialize the AragonApp
     * @param _name Token name
     * @param _symbol Token symbol
     */
    function initialize(string _name, string _symbol) public onlyInit {
        require(bytes(_name).length != 0);
        require(bytes(_symbol).length != 0);

        configureToken(_name, _symbol);
        initialized();
    }
    
    /**
     * @dev Function to mint NFT tokens, only those who have the `MINT_ROLE` 
     * persmission will be able to do it 
     * @param _to The address that will own the minted token
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender
     */
    function mint(address _to, uint256 _tokenId) auth(MINT_ROLE) public {
        _mint(_to, _tokenId);
    }

    /**
     * @dev Function to burn a specific NFT token, only those who have the `BURN_ROLE` 
     * persmission will be able to do it 
     * Reverts if the token does not exist
     * @param _tokenId uint256 ID of the token being burned by the msg.sender
    */
    function burn(uint256 _tokenId) auth(BURN_ROLE) public {
        require(msg.sender == _ownerOf(_tokenId));
        _burn(_ownerOf(_tokenId), _tokenId);
    }

    /**
     * @dev Function to set the token URI for a given token, only those who have the `MINT_ROLE` 
     * persmission will be able to do it
     * Reverts if the token ID does not exist
     * @param _tokenId uint256 ID of the token to set its URI
     * @param _uri string URI to assign
     */
    function setTokenURI(uint256 _tokenId, string _uri) auth(MINT_ROLE) public {
        _setTokenURI(_tokenId, _uri);
    }

    /**
     * @dev Function to clear current approval of a given token ID, only the owner of the token 
     * can do it 
     * Reverts if the given address is not indeed the owner of the token
     * @param _owner owner of the token
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function clearApproval(address _owner, uint256 _tokenId) public {
        require(msg.sender == _ownerOf(_tokenId));
        _clearApproval(_owner, _tokenId);
    }

    /**
     * @dev Returns whether the specified token exists
     * @param _tokenId uint256 ID of the token to query the existence of
     * @return whether the token exists
     */
    function exists(uint256 _tokenId) public view returns (bool) {
        return _exists(_tokenId);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner
     * @param _owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function tokensOfOwner(address _owner) public view returns (uint256[] memory) {
        return _tokensOfOwner(_owner);
    }
}