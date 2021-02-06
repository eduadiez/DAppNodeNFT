pragma solidity ^0.4.24;


import "@aragon/os/contracts/lib/math/SafeMath.sol";
import "@aragon/os/contracts/common/IsContract.sol";
import "./IERC721Receiver.sol";
import "./ERC165.sol";
import "./Strings.sol";

/* solium-disable function-order */

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC165, IsContract {
    using SafeMath for uint256;

    /**
     * @dev This emits when ownership of any NFT changes by any mechanism.
     * This event emits when NFTs are created (`from` == 0) and destroyed
     * (`to` == 0). Exception: during contract creation, any number of NFTs
     * may be created and assigned without emitting Transfer. At the time of
     * any transfer, the approved address for that NFT (if any) is reset to none.
     */
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /**
     * @dev This emits when the approved address for an NFT is changed or
     * reaffirmed. The zero address indicates there is no approved address.
     * When a Transfer event emits, this also indicates that the approved
     * address for that NFT (if any) is reset to none.
     */
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /**
     * @dev This emits when an operator is enabled or disabled for an owner.
     * The operator can manage all NFTs of the owner.
     */
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
    /*
     * 0x80ac58cd ===
     *     bytes4(keccak256('balanceOf(address)')) ^
     *     bytes4(keccak256('ownerOf(uint256)')) ^
     *     bytes4(keccak256('approve(address,uint256)')) ^
     *     bytes4(keccak256('getApproved(uint256)')) ^
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) ^
     *     bytes4(keccak256('isApprovedForAll(address,address)')) ^
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
     */

    bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;
    /**
     * 0x780e9d63 ===
     *     bytes4(keccak256('totalSupply()')) ^
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
     *     bytes4(keccak256('tokenByIndex(uint256)'))
     */

    bytes4 private constant _InterfaceId_ERC721Metadata = 0x5b5e139f;
    /**
     * 0x5b5e139f ===
     *     bytes4(keccak256('name()')) ^
     *     bytes4(keccak256('symbol()')) ^
     *     bytes4(keccak256('tokenURI(uint256)'))
     */

    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
    /**
     * 0x01ffc9a7 ===
     *     bytes4(keccak256('supportsInterface(bytes4)'))
     */

    string private _baseURI;
     
    function configureToken(string name, string symbol) internal {

        require(bytes(_name).length == 0 && bytes(_symbol).length == 0);

        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_InterfaceId_ERC165);
        _registerInterface(_InterfaceId_ERC721);
        _registerInterface(_InterfaceId_ERC721Metadata);
        _registerInterface(_InterfaceId_ERC721Enumerable);
    }

    /**
    * @notice A descriptive name for a collection of NFTs in this contract
    * @dev Gets the token name
    * @return string representing the token name
    */
    function name() external view returns (string) {
        return _name;
    }

    /**
     * @notice An abbreviated name for NFTs in this contract
     * @dev Gets the token symbol (metadata extension)
     * @return string representing the token symbol
     */
    function symbol() external view returns (string) {
        return _symbol;
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @dev Returns an URI for a given token ID
     * Throws if the `_tokenId` does not exist. May return an empty string.
     * URIs are defined in RFC3986. The URI may point to a JSON file that 
     * conforms to the "ERC721 Metadata JSON Schema".
     * @param _tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 _tokenId) external view returns (string){
        require(_exists(_tokenId));
        string memory _tokenURI = _tokenURIs[_tokenId];

        // Even if there is a base URI, it is only appended to non-empty token-specific URIs
        if (bytes(_tokenURI).length == 0) {
            return string(abi.encodePacked(_baseURI, Strings.toString(_tokenId)));
        } else {
            // abi.encodePacked is being used to concatenate strings
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
    }

    /**
     * @notice Count all NFTs assigned to an owner
     * @dev Gets the balance of the specified address. NFTs assigned to the zero 
     * address are considered invalid, and this function throws for queries about
     * the zero address.
     * @param _owner An address for whom to query the balance
     * @return uint256 representing number of NFTs owned by `_owner`, possibly zero 
     */
    function balanceOf(address _owner) external view returns (uint256) {
        return _balanceOf(_owner);
    }

    /**
     * @notice Find the owner of an NFT
     * @dev Gets the owner of the specified token ID. NFTs assigned to zero address
     * are considered invalid, and queries about them do throw.
     * @param _tokenId uint256 ID of the token to query the owner of
     * @return The owner address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _ownerOf(_tokenId);
    }

    /**
     * @notice Transfers the ownership of an NFT from one address to another address
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted. Throws unless `msg.sender` is the current owner, an authorized 
     * operator, or the approved address for this NFT. Throws if `_from` is not the current owner. 
     * Throws if `_to` is the zero address. Throws if  `_tokenId` is not a valid NFT.
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external payable {
        // it does not accept payments in this version
        require(msg.value == 0);

        // solium-disable-next-line arg-overflow
        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    /**
     * @notice Transfers the ownership of an NFT from one address to another address
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted. Throws unless `msg.sender` is the current owner, an authorized 
     * operator, or the approved address for this NFT. Throws if `_from` is not the current owner. 
     * Throws if `_to` is the zero address. Throws if  `_tokenId` is not a valid NFT.
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        // it does not accept payments in this version
        require(msg.value == 0);

        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    /**
     * @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
     *  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
     *  THEY MAY BE PERMANENTLY LOST
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Throws unless `msg.sender` is the current owner, an authorized
     * operator, or the approved address for this NFT. Throws if `_from` is
     * not the current owner. Throws if `_to` is the zero address. Throws if
     * `_tokenId` is not a valid NFT.
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        // it does not accept payments in this version
        require(msg.value == 0);

        _transferFrom(_from, _to, _tokenId);
    }

    /**
     * @notice Change or reaffirm the approved address for an NFT
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param _to address to be approved for the given token ID
     * @param _tokenId uint256 ID of the token to be approved
     */
    function approve(address _to, uint256 _tokenId) external payable {
        // it does not accept payments in this version
        require(msg.value == 0);

        address owner = _ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || _isApprovedForAll(owner, msg.sender));

        _tokenApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
    }

    /**
     * @notice Enable or disable approval for a third party ("operator") to manage
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * Emits the ApprovalForAll event. The contract MUST allow
     * multiple operators per owner.
     * @param _operator operator address to set the approval
     * @param _approved representing the status of the approval to be set
     */
    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != msg.sender);
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * @notice Get the approved address for a single NFT
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist. 
     * @param _tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 _tokenId) external view returns (address) {
        return _getApproved(_tokenId);
    }

    /**
     * @notice Query if an address is an authorized operator for another address 
     * @dev Tells whether an operator is approved by a given owner
     * @param _owner owner address which you want to query the approval of
     * @param _operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _isApprovedForAll(_owner,_operator);
    }

    /**
     * @notice Count NFTs tracked by this contract
     * @dev Gets the total amount of tokens stored by the contract
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() external view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @notice Enumerate valid NFTs
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens
     * @param _index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < _allTokens.length);
        return _allTokens[_index];
    }

    /**
     * @notice Enumerate NFTs assigned to an owner
     * @dev Gets the token ID at a given index of the tokens list of the requested owner 
     * Throws if `_index` >= `balanceOf(_owner)` or if `_owner` is the zero address, representing invalid NFTs.
     * @param _owner address owning the tokens list to be accessed
     * @param _index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        require(_owner != address(0));
        require(_index < _balanceOf(_owner));
        return _ownedTokens[_owner][_index];
    }

    /**
     * @notice Count all NFTs assigned to an owner
     * @dev Gets the balance of the specified address. NFTs assigned to the zero 
     * address are considered invalid, and this function throws for queries about
     * the zero address.
     * @param _owner An address for whom to query the balance
     * @return uint256 representing number of NFTs owned by `_owner`, possibly zero 
     */
    function _balanceOf(address _owner) internal view returns (uint256) {
        require(_owner != address(0));
        return _ownedTokens[_owner].length;
    }

    /**
     * @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
     *  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
     *  THEY MAY BE PERMANENTLY LOST
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Throws unless `msg.sender` is the current owner, an authorized
     * operator, or the approved address for this NFT. Throws if `_from` is
     * not the current owner. Throws if `_to` is the zero address. Throws if
     * `_tokenId` is not a valid NFT.
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
    */
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(_isApprovedOrOwner(msg.sender, _tokenId));
        require(_to != address(0));

        _clearApproval(_from, _tokenId);
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    /**
     * @notice Transfers the ownership of an NFT from one address to another address
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted. Throws unless `msg.sender` is the current owner, an authorized 
     * operator, or the approved address for this NFT. Throws if `_from` is not the current owner. 
     * Throws if `_to` is the zero address. Throws if  `_tokenId` is not a valid NFT.
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) internal {
        _transferFrom(_from, _to, _tokenId);
        // solium-disable-next-line arg-overflow
        require(_checkOnERC721Received(_from, _to, _tokenId, _data));
    }

    /**
     * @notice Query if an address is an authorized operator for another address 
     * @dev Tells whether an operator is approved by a given owner
     * @param _owner owner address which you want to query the approval of
     * @param _operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function _isApprovedForAll(address _owner, address _operator) internal view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    /**
     * @notice Check whether the given spender is an approved operator or the owner of a given token ID
     * @dev Returns whether the given spender can transfer a given token ID
     * @param _spender address of the spender to query
     * @param _tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *    is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = _ownerOf(_tokenId);
        // Disable solium check because of
        // https://github.com/duaraghav8/Solium/issues/175
        // solium-disable-next-line operator-whitespace
        return (_spender == owner || _getApproved(_tokenId) == _spender || _isApprovedForAll(owner, _spender));
    }

    /**
     * @notice Get the approved address for a single NFT
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist. 
     * @param _tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function _getApproved(uint256 _tokenId) internal view returns (address) {
        require(_exists(_tokenId));
        return _tokenApprovals[_tokenId];
    }

    /**
     * @notice Mint a new NFT token 
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param _to The address that will own the minted token
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender
     */
    function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0));
        _addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    /**
    * @dev Internal function to burn a specific token
    * Reverts if the token does not exist
    * @param _owner owner of the token
    * @param _tokenId uint256 ID of the token being burned by the msg.sender
    */
    function _burn(address _owner, uint256 _tokenId) internal {
        _clearApproval(_owner, _tokenId);
        _removeTokenFrom(_owner, _tokenId);

        // Reorg all tokens array
        uint256 tokenIndex = _allTokensIndex[_tokenId];
        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 lastToken = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastToken;
        _allTokens[lastTokenIndex] = 0;

        _allTokens.length--;
        _allTokensIndex[_tokenId] = 0;
        _allTokensIndex[lastToken] = tokenIndex;

        // Clear metadata (if any)
        if (bytes(_tokenURIs[_tokenId]).length != 0) {
            delete _tokenURIs[_tokenId];
        }

        emit Transfer(_owner, address(0), _tokenId);
    }

    /**
     * @notice Find the owner of an NFT
     * @dev Gets the owner of the specified token ID. NFTs assigned to zero address
     * are considered invalid, and queries about them do throw.
     * @param _tokenId uint256 ID of the token to query the owner of
     * @return The owner address currently marked as the owner of the given token ID
     */
    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

    /**
     * @dev Internal function to add a token ID to the list of a given address
     * Note that this function is left internal to make ERC721Enumerable possible, but is not
     * intended to be called by custom derived contracts: in particular, it emits no Transfer event.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenTo(address to, uint256 tokenId) internal {
        require(_tokenOwner[tokenId] == address(0));

        uint256 length = _ownedTokens[to].length;

        _tokenOwner[tokenId] = to;
        _ownedTokens[to].push(tokenId);
        _ownedTokensIndex[tokenId] = length;
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Internal function to set the token URI for a given token
     * Reverts if the token ID does not exist
     * @param _tokenId uint256 ID of the token to set its URI
     * @param _uri string URI to assign
     */
    function _setTokenURI(uint256 _tokenId, string _uri) internal {
        require(_exists(_tokenId));
        _tokenURIs[_tokenId] = _uri;
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Internal function to remove a token ID from the list of a given address
     * Note that this function is left internal to make ERC721Enumerable possible, but is not
     * intended to be called by custom derived contracts: in particular, it emits no Transfer event,
     * and doesn't clear approvals.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFrom(address from, uint256 tokenId) internal {
        require(_ownerOf(tokenId) == from);
        _tokenOwner[tokenId] = address(0);

        // To prevent a gap in the array, we store the last token in the index of the token to delete, and
        // then delete the last slot.
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 lastToken = _ownedTokens[from][lastTokenIndex];

        _ownedTokens[from][tokenIndex] = lastToken;
        // This also deletes the contents at the last position of the array
        _ownedTokens[from].length--;

        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
        // be zero. Then we can make sure that we will remove tokenId from the ownedTokens list since we are first swapping
        // the lastToken to the first position, and then dropping the element placed in the last position of the list

        _ownedTokensIndex[tokenId] = 0;
        _ownedTokensIndex[lastToken] = tokenIndex;
    }

    /**
     * @dev Gets the list of token IDs of the requested owner
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes _data) internal returns (bool) {
        if (!isContract(to)) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }


    /**
     * @dev Private function to clear current approval of a given token ID
     * Reverts if the given address is not indeed the owner of the token
     * @param _owner owner of the token
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(address _owner, uint256 _tokenId) internal {
        require(_ownerOf(_tokenId) == _owner);
        if (_tokenApprovals[_tokenId] != address(0)) {
            _tokenApprovals[_tokenId] = address(0);
        }
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI}.
     *
     * _Available since v2.5.0._
     */
    function _setBaseURI(string memory baseURI) internal {
        _baseURI = baseURI;
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a preffix in {tokenURI} to each token's URI, when
    * they are non-empty.
    *
    * _Available since v2.5.0._
    */
    function baseURI() external view returns (string memory) {
        return _baseURI;
    }
}