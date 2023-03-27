const {expect} = require("chai");
const {ContractFactory, utils, BigNumber} = require('ethers');
describe("Barcode", function () {
    let PunkBlocks, pb;
    let Render, render, testing2, Testing2
    describe("BarcodeRender", function () {
        it("render a barcode", async function () {
            let Barcode = await ethers.getContractFactory("Barcode");
            let bar = await Barcode.deploy();
            await bar.deployed();

            await bar.draw(31488755, [48], [48]);

        });
    })


});