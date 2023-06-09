import { BigNumber, ethers } from 'ethers';
import { maxUint, maxInt, minInt, bn } from './numbers';

export const MAX_UINT256: BigNumber = maxUint(256);
export const MAX_UINT112: BigNumber = maxUint(112);
export const MAX_UINT96: BigNumber = maxUint(96);
export const MAX_UINT10: BigNumber = maxUint(10);
export const MAX_UINT31: BigNumber = maxUint(31);
export const MAX_UINT32: BigNumber = maxUint(32);
export const MAX_UINT64: BigNumber = maxUint(64);

export const MIN_INT22: BigNumber = minInt(22);
export const MAX_INT22: BigNumber = maxInt(22);
export const MIN_INT53: BigNumber = minInt(53);
export const MAX_INT53: BigNumber = maxInt(53);
export const MIN_INT256: BigNumber = minInt(256);
export const MAX_INT256: BigNumber = maxInt(256);

export const ANY_ADDRESS = '0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF';
export const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
export const ZERO_BYTES32 = '0x0000000000000000000000000000000000000000000000000000000000000000';
export const ONES_BYTES32 = '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';

export const MAX_GAS_LIMIT = 8e6;
export const MAX_WEIGHTED_TOKENS = 100;

export const DELEGATE_OWNER = '0xBA1BA1ba1BA1bA1bA1Ba1BA1ba1BA1bA1ba1ba1B';

export const MAX_IN_RATIO = bn('0.3e18');
export const MAX_OUT_RATIO = bn('0.3e18');
export const MAX_RELATIVE_ERROR = 0.0001; //Max relative error

// This is not quite a constant, but it fits here given we also have ZERO_ADDRESS, etc.
export function randomAddress(): string {
  return ethers.Wallet.createRandom().address;
}

// 0x00: Used for generic compiler inserted panics.
export const GENERIC_PANIC = '0x00';
//0x01: If you call assert with an argument that evaluates to false.
export const ASSERT_PANIC = '0x01';
//0x11: If an arithmetic operation results in underflow or overflow outside of an unchecked { ... } block.
export const ARITHMETIC_FLOW_PANIC = '0x11';
//0x12; If you divide or modulo by zero (e.g. 5 / 0 or 23 % 0).
export const DIVISION_BY_ZERO_PANIC = '0x12';
//0x21: If you convert a value that is too big or negative into an enum type.
export const WRONG_ENUM_VALUE_PANIC = '0x21';
//0x22: If you access a storage byte array that is incorrectly encoded.
export const STORAGE_ARRAY_WRONG_ENCODING_PANIC = '0x22';
//0x31: If you call .pop() on an empty array.
export const EMPTY_ARRAY_POP_PANIC = '0x31';
//0x32: If you access an array, bytesN or an array slice at an out-of-bounds or negative index.
export const ARRAY_OUT_OF_BOUNDS_PANIC = '0x32';
//0x41: If you allocate too much memory or create an array that is too large.
export const OUT_OF_MEMORY_PANIC = '0x41';
//0x51: If you call a zero-initialized variable of internal function type.
export const INTERNAL_ZERO_CALL_PANIC = '0x51';
