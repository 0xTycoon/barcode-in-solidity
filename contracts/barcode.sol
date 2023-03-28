// SPDX-License-Identifier: MIT
// Author: tycoon.eth
pragma solidity ^0.8.19;

/***
___.
\_ |__ _____ _______
 | __ \\__  \\_  __ \
 | \_\ \/ __ \|  | \/
 |___  (____  /__|
     \/     \/
                 .___
  ____  ____   __| _/____
_/ ___\/  _ \ / __ |/ __ \
\  \__(  <_> ) /_/ \  ___/
 \___  >____/\____ |\___  >
     \/           \/    \/

Generate barcodes SVGs on-chain.
Limitations: Code-128 Character set C only.


**/


contract Barcode {
    using DynamicBufferLib for DynamicBufferLib.DynamicBuffer;
    mapping(bytes32 => bytes11) public barMap;

    bytes13 constant stopCode = "1100011101011";

    constructor() {
        // Lookup table of Character Set C of Code-128
        barMap["00"] = "11011001100";
        barMap["01"] = "11001101100";
        barMap["02"] = "11001100110";
        barMap["03"] = "10010011000";
        barMap["04"] = "10010001100";
        barMap["05"] = "10001001100";
        barMap["06"] = "10011001000";
        barMap["07"] = "10011000100";
        barMap["08"] = "10001100100";
        barMap["09"] = "11001001000";
        barMap["10"] = "11001000100";
        barMap["11"] = "11000100100";
        barMap["12"] = "10110011100";
        barMap["13"] = "10011011100";
        barMap["14"] = "10011001110";
        barMap["15"] = "10111001100";
        barMap["16"] = "10011101100";
        barMap["17"] = "10011100110";
        barMap["18"] = "11001110010";
        barMap["19"] = "11001011100";
        barMap["20"] = "11001001110";
        barMap["21"] = "11011100100";
        barMap["22"] = "11001110100";
        barMap["23"] = "11101101110";
        barMap["24"] = "11101001100";
        barMap["25"] = "11100101100";
        barMap["26"] = "11100100110";
        barMap["27"] = "11101100100";
        barMap["28"] = "11100110100";
        barMap["29"] = "11100110010";
        barMap["30"] = "11011011000";
        barMap["31"] = "11011000110";
        barMap["32"] = "11000110110";
        barMap["33"] = "10100011000";
        barMap["34"] = "10001011000";
        barMap["35"] = "10001000110";
        barMap["36"] = "10110001000";
        barMap["37"] = "10001101000";
        barMap["38"] = "10001100010";
        barMap["39"] = "11010001000";
        barMap["40"] = "11000101000";
        barMap["41"] = "11000100010";
        barMap["42"] = "10110111000";
        barMap["43"] = "10110001110";
        barMap["44"] = "10001101110";
        barMap["45"] = "10111011000";
        barMap["46"] = "10111000110";
        barMap["47"] = "10001110110";
        barMap["48"] = "11101110110";
        barMap["49"] = "11010001110";
        barMap["50"] = "11000101110";
        barMap["51"] = "11011101000";
        barMap["52"] = "11011100010";
        barMap["53"] = "11011101110";
        barMap["54"] = "11101011000";
        barMap["55"] = "11101000110";
        barMap["56"] = "11100010110";
        barMap["57"] = "11101101000";
        barMap["58"] = "11101100010";
        barMap["59"] = "11100011010";
        barMap["60"] = "11101111010";
        barMap["61"] = "11001000010";
        barMap["62"] = "11110001010";
        barMap["63"] = "10100110000";
        barMap["64"] = "10100001100";
        barMap["65"] = "10010110000";
        barMap["66"] = "10010000110";
        barMap["67"] = "10000101100";
        barMap["68"] = "10000100110";
        barMap["69"] = "10110010000";
        barMap["70"] = "10110000100";
        barMap["71"] = "10011010000";
        barMap["72"] = "10011000010";
        barMap["73"] = "10000110100";
        barMap["74"] = "10000110010";
        barMap["75"] = "11000010010";
        barMap["76"] = "11001010000";
        barMap["77"] = "11110111010";
        barMap["78"] = "11000010100";
        barMap["79"] = "10001111010";
        barMap["80"] = "10100111100";
        barMap["81"] = "10010111100";
        barMap["82"] = "10010011110";
        barMap["83"] = "10111100100";
        barMap["84"] = "10011110100";
        barMap["85"] = "10011110010";
        barMap["86"] = "11110100100";
        barMap["87"] = "11110010100";
        barMap["88"] = "11110010010";
        barMap["89"] = "11011011110";
        barMap["90"] = "11011110110";
        barMap["91"] = "11110110110";
        barMap["92"] = "10101111000";
        barMap["93"] = "10100011110";
        barMap["94"] = "10001011110";
        barMap["95"] = "10111101000";
        barMap["96"] = "10111100010";
        barMap["97"] = "11110101000";
        barMap["98"] = "11110100010";
        barMap["99"] = "10111011110";
        barMap["100"] = "10111101110";  // code B
        barMap["101"] = "11101011110";  // code A
        barMap["102"] = "11110101110";  // FNC1
        barMap["103"] = "11010000100";  // START A
        barMap["104"] = "11010010000";  // START B
        barMap["105"] = "11010011100";  // START C

    }

    /**
    * @dev draw returns the SVG string that renders a barcode
    * @param _in the number to draw as a barcode
    * @param _x x position of the SVG
    * @param _y y position of the SVG
    * @param _color a 3 byte hex code of the background color
    * @param _height height in pixels, min 20
    * @param _barWidth width of bars, recommended: 2
    */
    function draw(
        uint256 _in,
        string memory _x,
        string memory _y,
        string memory _color,
        uint16 _height,
        uint8 _barWidth) view external returns (string memory) {
        bytes memory digits = bytes(toString(_in));
        bytes memory out =
            abi.encodePacked(barMap["105"]);   // charset-C
        if (digits.length % 2 == 1) {
            digits = abi.encodePacked(
                "0", digits);                  // prepend 0 so that it's even
        }
        uint256 pos;                           // position when parsing digits
        uint256 n;                             // value of character
        uint256 sum = 105;                     // checksum, starting with set-C code, 105
        uint256 i = 1;                         // position, used for the checksum
        bytes32 k;                             // lookup key
        bytes memory b = "00";                 // buffer used to build the lookup-key
        while (pos < digits.length) {
            b[0] = digits[pos];
            b[1] = digits[pos+1];
            assembly {
                k := mload(add(b, 32))         // convert b to k (bytes32)
            }
            out = abi.encodePacked(
                out, barMap[k]);
            n = (uint8(digits[pos]) - 48) * 10;// convert to int, big
            n += uint8(digits[pos+1]) - 48;    // convert to int, small
            sum = sum + (n*i);                 // add to checksum
            pos+=2;
            i++;
        }
        sum = sum % 103; // checksum
        b = bytes(toString(sum));
        if (sum < 10) {
            b = abi.encodePacked("0", b);      // pad with "0"
        }
        assembly {
            k := mload(add(b, 32))             // convert b to k (bytes32)
        }
        out = abi.encodePacked(
            out, barMap[k], stopCode);
        return string(_render(
            out,
            bytes(_x),
            bytes(_y),
            bytes(_color),
            _height,
            _barWidth)
        );
    }

    /**
    * _render
    */
    function _render(
        bytes memory _in,
        bytes memory _x,
        bytes memory _y,
        bytes memory _color,
        uint16 _height,
        uint8 _barWidth
) internal pure returns (bytes memory) {
        require (_height > 19, "_height too small");
        DynamicBufferLib.DynamicBuffer memory result;
        uint256 pos = 0;
        uint256 i = 0;
        uint256 n = 0;
        bytes memory width = bytes(toString((_in.length * _barWidth) + 24)); // auto-width
        bytes memory height = bytes(toString(uint256(_height)));
        result.append('<svg id="solbarcode" x="', _x, 'px" y="');
        result.append(_y, 'px" width="', width);
        result.append('px" height="', height,'px" viewBox="0 0 ');
        result.append(width,' ', height);
        result.append('" xmlns="http://www.w3.org/2000/svg" version="1.1"><rect x="0" y="0" width="');
        result.append(width,'" height="', height);
        result.append('" style="fill:#',_color,';"/> <g transform="translate(12, 10)" style="fill:#0;">');
        while (pos < _in.length) {
            if (_in[pos] == "1") {
                i++;     // count the black bars
                if (n > 0) {
                    n =0;
                }
            } else {
                if (i>0) { //
                    result.append(
                        ' <rect x="',
                        bytes(toString(pos * _barWidth - (i * _barWidth))),
                        '" y="0" width="');
                    result.append(
                        bytes(toString(i * _barWidth)),
                        '" height="',
                        bytes(toString(_height - 20)));
                    result.append('"/>');
                    i=0;
                }
                n++;
            }
            pos++;
        }
        if (i>0) {
            result.append(
                ' <rect x="',
                bytes(toString(pos * _barWidth - (i * _barWidth))),
                '" y="0" width="');
            result.append(
                bytes(toString(i * _barWidth)),
                '" height="',
                bytes(toString(_height - 20)));
            result.append('"/>');
        }
        result.append('</g></svg>');
        return (result.data);
    }

    function toString(uint256 value) public pure returns (string memory) {
        // Inspired by openzeppelin's implementation - MIT licence
        // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol#L15
        // this version removes the decimals counting
        uint8 count;
        if (value == 0) {
            return "0";
        }
        uint256 digits = 31;
        // bytes and strings are big endian, so working on the buffer from right to left
        // this means we won't need to reverse the string later
        bytes memory buffer = new bytes(32);
        while (value != 0) {
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
            digits -= 1;
            count++;
        }
        uint256 temp;
        assembly {
            temp := mload(add(buffer, 32))
            temp := shl(mul(sub(32,count),8), temp)
            mstore(add(buffer, 32), temp)
            mstore(buffer, count)
        }
        return string(buffer);
    }
}

/**
* DynamicBufferLib adapted from
* https://github.com/Vectorized/solady/blob/main/src/utils/DynamicBufferLib.sol
*/
library DynamicBufferLib {
    /// @dev Type to represent a dynamic buffer in memory.
    /// You can directly assign to `data`, and the `append` function will
    /// take care of the memory allocation.
    struct DynamicBuffer {
        bytes data;
    }

    /// @dev Appends `data` to `buffer`.
    /// Returns the same buffer, so that it can be used for function chaining.
    function append(DynamicBuffer memory buffer, bytes memory data)
    internal
    pure
    returns (DynamicBuffer memory)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(data) {
                let w := not(31)
                let bufferData := mload(buffer)
                let bufferDataLength := mload(bufferData)
                let newBufferDataLength := add(mload(data), bufferDataLength)
            // Some random prime number to multiply `capacity`, so that
            // we know that the `capacity` is for a dynamic buffer.
            // Selected to be larger than any memory pointer realistically.
                let prime := 1621250193422201
                let capacity := mload(add(bufferData, w))

            // Extract `capacity`, and set it to 0, if it is not a multiple of `prime`.
                capacity := mul(div(capacity, prime), iszero(mod(capacity, prime)))

            // Expand / Reallocate memory if required.
            // Note that we need to allocate an exta word for the length, and
            // and another extra word as a safety word (giving a total of 0x40 bytes).
            // Without the safety word, the data at the next free memory word can be overwritten,
            // because the backwards copying can exceed the buffer space used for storage.
                for {} iszero(lt(newBufferDataLength, capacity)) {} {
                // Approximately double the memory with a heuristic,
                // ensuring more than enough space for the combined data,
                // rounding up to the next multiple of 32.
                    let newCapacity :=
                    and(add(capacity, add(or(capacity, newBufferDataLength), 32)), w)

                // If next word after current buffer is not eligible for use.
                    if iszero(eq(mload(0x40), add(bufferData, add(0x40, capacity)))) {
                    // Set the `newBufferData` to point to the word after capacity.
                        let newBufferData := add(mload(0x40), 0x20)
                    // Reallocate the memory.
                        mstore(0x40, add(newBufferData, add(0x40, newCapacity)))
                    // Store the `newBufferData`.
                        mstore(buffer, newBufferData)
                    // Copy `bufferData` one word at a time, backwards.
                        for { let o := and(add(bufferDataLength, 32), w) } 1 {} {
                            mstore(add(newBufferData, o), mload(add(bufferData, o)))
                            o := add(o, w) // `sub(o, 0x20)`.
                            if iszero(o) { break }
                        }
                    // Store the `capacity` multiplied by `prime` in the word before the `length`.
                        mstore(add(newBufferData, w), mul(prime, newCapacity))
                    // Assign `newBufferData` to `bufferData`.
                        bufferData := newBufferData
                        break
                    }
                // Expand the memory.
                    mstore(0x40, add(bufferData, add(0x40, newCapacity)))
                // Store the `capacity` multiplied by `prime` in the word before the `length`.
                    mstore(add(bufferData, w), mul(prime, newCapacity))
                    break
                }
            // Initalize `output` to the next empty position in `bufferData`.
                let output := add(bufferData, bufferDataLength)
            // Copy `data` one word at a time, backwards.
                for { let o := and(add(mload(data), 32), w) } 1 {} {
                    mstore(add(output, o), mload(add(data, o)))
                    o := add(o, w) // `sub(o, 0x20)`.
                    if iszero(o) { break }
                }
            // Zeroize the word after the buffer.
                mstore(add(add(bufferData, 0x20), newBufferDataLength), 0)
            // Store the `newBufferDataLength`.
                mstore(bufferData, newBufferDataLength)
            }
        }
        return buffer;
    }
    /*
        /// @dev Appends `data0`, `data1` to `buffer`.
    /// Returns the same buffer, so that it can be used for function chaining.
    function append(DynamicBuffer memory buffer, bytes memory data0, bytes memory data1)
    internal
    pure
    returns (DynamicBuffer memory)
    {
        return append(append(buffer, data0), data1);
    }
*/
    /// @dev Appends `data0`, `data1`, `data2` to `buffer`.
    /// Returns the same buffer, so that it can be used for function chaining.
    function append(
        DynamicBuffer memory buffer,
        bytes memory data0,
        bytes memory data1,
        bytes memory data2
    ) internal pure returns (DynamicBuffer memory) {
        return append(append(append(buffer, data0), data1), data2);
    }
    /*

        /// @dev Appends `data0`, `data1`, `data2`, `data3` to `buffer`.
    /// Returns the same buffer, so that it can be used for function chaining.
    function append(
        DynamicBuffer memory buffer,
        bytes memory data0,
        bytes memory data1,
        bytes memory data2,
        bytes memory data3
    ) internal pure returns (DynamicBuffer memory) {
        return append(append(append(append(buffer, data0), data1), data2), data3);
    }

    /// @dev Appends `data0`, `data1`, `data2`, `data3`, `data4` to `buffer`.
    /// Returns the same buffer, so that it can be used for function chaining.
    function append(
        DynamicBuffer memory buffer,
        bytes memory data0,
        bytes memory data1,
        bytes memory data2,
        bytes memory data3,
        bytes memory data4
    ) internal pure returns (DynamicBuffer memory) {
        append(append(append(append(buffer, data0), data1), data2), data3);
        return append(buffer, data4);
    }

    /// @dev Appends `data0`, `data1`, `data2`, `data3`, `data4`, `data5` to `buffer`.
    /// Returns the same buffer, so that it can be used for function chaining.
    function append(
        DynamicBuffer memory buffer,
        bytes memory data0,
        bytes memory data1,
        bytes memory data2,
        bytes memory data3,
        bytes memory data4,
        bytes memory data5
    ) internal pure returns (DynamicBuffer memory) {
        append(append(append(append(buffer, data0), data1), data2), data3);
        return append(append(buffer, data4), data5);
    }

    /// @dev Appends `data0`, `data1`, `data2`, `data3`, `data4`, `data5`, `data6` to `buffer`.
    /// Returns the same buffer, so that it can be used for function chaining.
    function append(
        DynamicBuffer memory buffer,
        bytes memory data0,
        bytes memory data1,
        bytes memory data2,
        bytes memory data3,
        bytes memory data4,
        bytes memory data5,
        bytes memory data6
    ) internal pure returns (DynamicBuffer memory) {
        append(append(append(append(buffer, data0), data1), data2), data3);
        return append(append(append(buffer, data4), data5), data6);
    }
    */
}