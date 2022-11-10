const { expect } = require("chai");
const { ethers } = require("hardhat");
describe("Escrow", async () => {
    let buyer;
    let seller;
    let token;
    let escrow;
  beforeEach(async () => {
  
    const signers = await ethers.getSigners();
    buyer = signers[0];
    seller = signers[1];
    const Token = await ethers.getContractFactory("Token");
    const token_ = await Token.deploy();
    await token_.deployed();
    console.log(`Token Deployed to ${token_.address}`);

    token = token_;

    const Escrow = await ethers.getContractFactory("Escrow");

    const escrow_ = await Escrow.deploy(buyer.address, seller.address, 20, token_.address);

    await escrow_.deployed();
    console.log(`Escrow deployed to ${escrow_.address}`);

   escrow = escrow_;
   
    await token_.connect(buyer).approve(escrow.address, 20);
  
  })
  it("should do complete transation", async function () {
    
    await escrow.connect(buyer).BuyerSendPayment();

    await escrow.connect(seller).confirmOrder();
    await escrow.connect(seller).deliver();
    await escrow.connect(buyer).confirmDelivery(true);
    setTimeout(()=>{
        escrow.connect(seller).claimFunds();
    },4000) 
    setTimeout(()=>{
        const bal = token.balanceOf(seller.address);
        expect(bal).to.equal(20);
    },5000) 
    

  });
});
