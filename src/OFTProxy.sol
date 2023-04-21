// SPDX-License-Identifier: MIT
// Adapted from https://github.com/LayerZero-Labs/solidity-examples

pragma solidity ^0.8.0;

import "./OFTCore.sol";
import {SafeTransferLib, ERC20} from "solmate/utils/SafeTransferLib.sol";

contract ProxyOFT is OFTCore {
    using SafeTransferLib for ERC20;

    ERC20 internal immutable innerToken;

    constructor(address _lzEndpoint, address _token) OFTCore(_lzEndpoint) {
        innerToken = ERC20(_token);
    }

    function circulatingSupply() public view virtual override returns (uint) {
        unchecked {
            return innerToken.totalSupply() - innerToken.balanceOf(address(this));
        }
    }

    function token() public view virtual override returns (address) {
        return address(innerToken);
    }

    function _debitFrom(address _from, uint16, bytes memory, uint _amount) internal virtual override returns(uint) {
        require(_from == msg.sender, "ProxyOFT: owner is not send caller");
        uint256 before = innerToken.balanceOf(address(this));
        innerToken.safeTransferFrom(_from, address(this), _amount);
        return innerToken.balanceOf(address(this)) - before;
    }

    function _creditTo(uint16, address _toAddress, uint _amount) internal virtual override returns(uint) {
        uint before = innerToken.balanceOf(_toAddress);
        innerToken.safeTransfer(_toAddress, _amount);
        return innerToken.balanceOf(_toAddress) - before;
    }
}