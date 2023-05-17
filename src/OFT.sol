// SPDX-License-Identifier: MIT
// Adapted from https://github.com/LayerZero-Labs/solidity-examples

pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IERC165.sol";
import "./interfaces/IOFT.sol";
import "./OFTCore.sol";

contract OFT is ERC20, OFTCore, IOFT {
    constructor(string memory _name, string memory _symbol, uint8 _decimals, address _lzEndpoint) ERC20(_name, _symbol, _decimals) OFTCore(_lzEndpoint) {}

    function supportsInterface(bytes4 interfaceId) public view virtual override(OFTCore, IERC165) returns (bool) {
        return interfaceId == type(IOFT).interfaceId || interfaceId == type(IERC20).interfaceId || super.supportsInterface(interfaceId);
    }

    function token() public view virtual override returns (address) {
        return address(this);
    }

    function circulatingSupply() public view virtual override returns (uint) {
        return totalSupply;
    }

    function _debitFrom(address _from, uint16, bytes memory, uint _amount) internal virtual override returns(uint) {
        address spender = msg.sender;
        if (_from != spender) {
            uint256 allowed = allowance[_from][spender];
            if (allowed != type(uint256).max) allowance[_from][spender] = allowed - _amount;
        }
        _burn(_from, _amount);
        return _amount;
    }

    function _creditTo(uint16, address _toAddress, uint _amount) internal virtual override returns(uint) {
        _mint(_toAddress, _amount);
        return _amount;
    }
}