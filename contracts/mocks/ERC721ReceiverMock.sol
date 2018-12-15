pragma solidity ^0.4.24;

contract ERC721ReceiverMock {
    bytes4 private _retval;
    bool private _reverts;

    event Received(address _operator, address _from, uint256 _tokenId, bytes _data, uint256 _gas);

    constructor (bytes4 retval, bool reverts) public {
        _retval = retval;
        _reverts = reverts;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes data) external returns (bytes4) {
        require(!_reverts);
        emit Received(operator, from, tokenId, data, gasleft());
        return _retval;
    }
}
