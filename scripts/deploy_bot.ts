/* eslint-disable prettier/prettier */
import '@nomiclabs/hardhat-ethers'
import { ethers } from 'hardhat'

async function main() {

  const Redeem = await ethers.getContractFactory('RedeemAndFee')
  const RedeemContract = await Redeem.deploy()

  console.log("Redeem Contract: ", RedeemContract.address)
  
  const factory = await ethers.getContractFactory('MarketFactory')

  // If we had constructor arguments, they would be passed into deploy()
  const contract = await factory.deploy()

  // The address the Contract WILL have once mined
  console.log('MarketFactory address', contract.address)

  const Main = await ethers.getContractFactory('Main')
  const mainContract = await Main.deploy()

  const ServiceMarketF = await ethers.getContractFactory('ServiceMarket');
  const ServiceMarket = await ServiceMarketF.deploy();

  const GiftF = await ethers.getContractFactory('Gift')
  const Gift = await GiftF.deploy();

  console.log('Main address: ', mainContract.address)
  console.log("service address", ServiceMarket.address)
  console.log("Gift Address", Gift.address)


  let tx = await contract.initialize("0xf827c3E5fD68e78aa092245D442398E12988901C")
  await tx.wait()
  console.log("===0===")

  tx = await contract.setMarketplace(mainContract.address)
  console.log("==1======")
  await tx.wait()
  tx = await RedeemContract.setFlatFee('1000000000000000')
  console.log("==2======")
  await tx.wait()
  tx = await mainContract.setMarketFactory(contract.address)
  await tx.wait()
  console.log("==3======")
  tx = await mainContract.setRedeemFeeContract(RedeemContract.address)
  await tx.wait()
  console.log("==4======")
  tx = await ServiceMarket.setRedeemFeeContract(RedeemContract.address)
  await tx.wait()

  console.log("=======5==========")
  tx = await Gift.setMarketPlace(mainContract.address)
  await tx.wait();
  console.log("=======6==========")
  tx = await RedeemContract.setMarketPlace(mainContract.address)
  await tx.wait();

  // tx = await mainContract.setAbleToViewALLPrivateMetadata("0xFaF6471d8E5e109Ad13435fc71E0776629C04858", true)
  // await tx.wait()
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
