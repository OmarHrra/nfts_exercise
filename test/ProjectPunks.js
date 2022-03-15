const { expect } = require('chai')

describe('Project punks contract', () => {
  const setup = async ({ maxSupply = 10000,   }) => {
    const [deployer] = await ethers.getSigners()
    const projectPunks = await ethers.getContractFactory('ProjectPunks')
    const deployed = await projectPunks.deploy(maxSupply)

    return {
      deployer,
      deployed
    }
  }

  describe('Deployement', () => {
    it('Sets max supply to passed param', async () => {
      const maxSupply = 4000
      const { deployed } = await setup({ maxSupply })
      const returnedMaxSupply = await deployed.maxSupply()

      expect(returnedMaxSupply).to.eq(maxSupply)
    })
  })

  describe('Minting', () => {
    it('Mints a new token and assigns it to owner', async () => {
      const { deployer, deployed } = await setup({})
      await deployed.mint()
      const ownerOfMinted = await deployed.ownerOf(0)

      expect(ownerOfMinted).to.eq(deployer.address)
    })

    it('Has a minting limit', async () => {
      const maxSupply = 2
      const { deployed } = await setup({ maxSupply })

      // Mint all
      // Promise.all([
      //   deployed.mint(),
      //   deployed.mint()
      // ])
      await deployed.mint()
      await deployed.mint()


      // Assert the last minting
      await expect(deployed.mint()).to.be.revertedWith('minting above the total token supply')
    })
  })

  describe('tokenURI', () => {
    it('returns valid metada', async () => {
      const { deployed } = await setup({})
      await deployed.mint()
      const tokenURI = await deployed.tokenURI(0)
      const stringifiedTokenURI = await tokenURI.toString()
      const [_prefix, base64JSON] = stringifiedTokenURI.split(
        'data:application/json;base64,'
      )

      const stringifiedMetadata = await Buffer.from(base64JSON, 'base64').toString('utf-8')
      const metadata = JSON.parse(stringifiedMetadata)

      expect(metadata).to.have.all.keys('name', 'description', 'image')
    })
  })
})