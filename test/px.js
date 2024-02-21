const { expect } = require("chai");

describe("PX contract", function () {

    it("Should transfer tokens between accounts", async function() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        const hardhatToken = await ethers.deployContract("PX");

        await hardhatToken.mint(0, {value: 0});
        console.log(await hardhatToken.balanceOf(owner.address));
        console.log(await hardhatToken.ownerOf(1));
        console.log(await hardhatToken.tokenURI(1));
        console.log("Gas: ", await hardhatToken.estimateGas.mint(0, {value: 0}));

    });
});