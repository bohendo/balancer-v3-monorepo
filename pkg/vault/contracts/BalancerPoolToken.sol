// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import { Nonces } from "@openzeppelin/contracts/utils/Nonces.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IVault } from "@balancer-labs/v3-interfaces/contracts/vault/IVault.sol";
import { IVaultErrors } from "@balancer-labs/v3-interfaces/contracts/vault/IVaultErrors.sol";

/**
 * @notice A fully ERC20-compatible token to be used as the base contract for Balancer Pools,
 * with all the data and implementation delegated to the ERC20Multitoken contract.

 * @dev Implementation of the ERC-20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[ERC-2612].
 */
contract BalancerPoolToken is IERC20, IERC20Metadata, IERC20Permit, EIP712, Nonces {
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    // @dev Permit deadline has expired.
    error ERC2612ExpiredSignature(uint256 deadline);

    // @dev Mismatched signature.
    error ERC2612InvalidSigner(address signer, address owner);

    IVault private immutable _vault;

    string private _name;
    string private _symbol;

    modifier onlyVault() {
        if (msg.sender != address(_vault)) {
            revert IVaultErrors.SenderIsNotVault(msg.sender);
        }
        _;
    }

    constructor(IVault vault_, string memory name_, string memory symbol_) EIP712(name_, "1") {
        _vault = vault_;
        _name = name_;
        _symbol = symbol_;
    }

    /// @inheritdoc IERC20Metadata
    function name() public view returns (string memory) {
        return _name;
    }

    /// @inheritdoc IERC20Metadata
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /// @inheritdoc IERC20Metadata
    function decimals() public pure returns (uint8) {
        // Always 18 decimals for BPT.
        return 18;
    }

    /// @inheritdoc IERC20
    function totalSupply() public view returns (uint256) {
        return _vault.totalSupply(address(this));
    }

    function getVault() public view returns (IVault) {
        return _vault;
    }

    /// @inheritdoc IERC20
    function balanceOf(address account) public view returns (uint256) {
        return _vault.balanceOf(address(this), account);
    }

    /// @inheritdoc IERC20
    function transfer(address to, uint256 amount) public returns (bool) {
        // Vault will perform the transfer and call emitTransfer to emit the event from this contract.
        _vault.transfer(msg.sender, to, amount);
        return true;
    }

    /// @inheritdoc IERC20
    function allowance(address owner, address spender) public view returns (uint256) {
        return _vault.allowance(address(this), owner, spender);
    }

    /// @inheritdoc IERC20
    function approve(address spender, uint256 amount) public returns (bool) {
        // Vault will perform the approval and call emitApproval to emit the event from this contract.
        _vault.approve(msg.sender, spender, amount);
        return true;
    }

    /// @inheritdoc IERC20
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        // Vault will perform the transfer and call emitTransfer to emit the event from this contract.
        _vault.transferFrom(msg.sender, from, to, amount);
        return true;
    }

    /// Accounting is centralized in the MultiToken contract, and the actual transfers and approvals
    /// are done there. Operations can be initiated from either the token contract or the MultiToken.
    ///
    /// To maintain compliance with the ERC-20 standard, and conform to the expections of off-chain processes,
    /// the MultiToken calls `emitTransfer` and `emitApproval` during those operations, so that the event is emitted
    /// only from the token contract. These events are NOT defined in the MultiToken contract.

    /// @dev Emit the Transfer event. This function can only be called by the MultiToken.
    function emitTransfer(address from, address to, uint256 amount) external onlyVault {
        emit Transfer(from, to, amount);
    }

    /// @dev Emit the Approval event. This function can only be called by the MultiToken.
    function emitApproval(address owner, address spender, uint256 amount) external onlyVault {
        emit Approval(owner, spender, amount);
    }

    // @inheritdoc IERC20Permit
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _vault.approve(owner, spender, amount);
    }

    // @inheritdoc IERC20Permit
    function nonces(address owner) public view virtual override(IERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    // @inheritdoc IERC20Permit
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}
