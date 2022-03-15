const deploy = async () => {
  const [deployer] = await ethers.getSigners()

  console.log('Deploying contracts with the account: ', deployer.address)

  const projectPunks = await ethers.getContractFactory('ProjectPunks')
  const deployed = await projectPunks.deploy(1000)

  console.log('Deployed at: ', deployed.address)
}

deploy().then(() => process.exit(0)).catch(error => {
  console.error(error)
  process.exit(1)
});