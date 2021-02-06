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
     * @notice Function to initialize the AragonApp
     * @dev it will revert if the name or symbol is not specified.
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
     * @notice Mint `_tokenId` and give the ownership to  `_to` 
     * @dev Only those who have the `MINT_ROLE` permission will be able to do it 
     * @param _to The address that will own the minted token
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender
     */
    function mint(address _to, uint256 _tokenId) auth(MINT_ROLE) public {
        _mint(_to, _tokenId);
    }

    /**
     * @notice Burn tokenId: `_tokenId`
     * @dev Only those who have the `BURN_ROLE` persmission will be able to do it
     * Reverts if the token does not exist
     * @param _tokenId uint256 ID of the token being burned by the msg.sender
    */
    function burn(uint256 _tokenId) auth(BURN_ROLE) public {
        require(msg.sender == _ownerOf(_tokenId));
        _burn(_ownerOf(_tokenId), _tokenId);
    }

    /**
     * @notice Set `_uri` for `_tokenId`, 
     * @dev Only those who have the `MINT_ROLE` persmission will be able to do it
     * Reverts if the token ID does not exist
     * @param _tokenId uint256 ID of the token to set its URI
     * @param _uri string URI to assign
     */
    function setTokenURI(uint256 _tokenId, string _uri) auth(MINT_ROLE) public {
        _setTokenURI(_tokenId, _uri);
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI}.
     *
     * _Available since v2.5.0._
     */
    function setBaseURI(string memory baseURI) auth(MINT_ROLE) public {
        _setBaseURI(baseURI);
    }

    /**
     * @notice Clear current approval of `_tokenId` owned by `_owner`,
     * @dev only the owner of the token can do it 
     * Reverts if the given address is not indeed the owner of the token
     * @param _owner owner of the token
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function clearApproval(address _owner, uint256 _tokenId) public {
        require(msg.sender == _ownerOf(_tokenId));
        _clearApproval(msg.sender, _tokenId);
    }

    /**
     * @notice Returns whether `_tokenId` exists
     * @dev Returns whether the specified token exists
     * @param _tokenId uint256 ID of the token to query the existence of
     * @return whether the token exists
     */
    function exists(uint256 _tokenId) public view returns (bool) {
        return _exists(_tokenId);
    }

    /**
     * @notice Gets the list of token IDs of the `_owner`
     * @dev Gets the list of token IDs of the requested owner
     * @param _owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function tokensOfOwner(address _owner) public view returns (uint256[] memory) {
        return _tokensOfOwner(_owner);
    }
}