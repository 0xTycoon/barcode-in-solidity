// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract TestCode {
    IBarcode public b;

    constructor(address _b) {
        b = IBarcode(_b);

        b.draw(55653, "0", "0", "c0c0c0", 32, 2);
    }
}

interface IBarcode {
    function draw(
        uint256 _in,
        string memory _x,
        string memory _y,
        string memory _color,
        uint16 _height,
        uint8 _barWidth) view external returns (string memory);
}