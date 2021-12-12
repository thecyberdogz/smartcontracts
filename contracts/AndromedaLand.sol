// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title AndromedaLand
 * AndromedaLand - a contract for semi-fungible tokens.
 */

contract AndromedaLand is ERC1155PresetMinterPauser, Ownable {
    address public proxyRegistryAddress;
    // Contract name
    string public name;
    // Contract symbol
    string public symbol;

    string private _contractUri;

    constructor(
        address _proxyRegistryAddress,
        uint256 _initialSupply,
        string memory _name,
        string memory _symbol
    ) ERC1155PresetMinterPauser("https://cyberdogz.s3.us-west-1.amazonaws.com/nft/andromeda/{id}.json") {
        proxyRegistryAddress = _proxyRegistryAddress;
        _mint(msg.sender, 1, _initialSupply, "");
        name = _name;
        symbol = _symbol;
        _contractUri = "https://cyberdogz.s3.us-west-1.amazonaws.com/nft/andromeda/contract.json";
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-free listings.
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }

        return ERC1155.isApprovedForAll(_owner, _operator);
    }

    function setURI(string memory _newUri) public onlyOwner {
        _setURI(_newUri);
    }

    function setContractURI(string memory _newUri) public onlyOwner {
        _contractUri = _newUri;
    }

    function contractURI() public view returns (string memory) {
        return _contractUri;
    }
}
