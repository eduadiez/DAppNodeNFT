const shouldFail = require('./helpers/shouldFail');
const { shouldBehaveLikeERC721 } = require('./ERC721.behavior');
const { shouldSupportInterfaces } = require('./SupportsInterface.behavior');

const DAOFactory = artifacts.require('@aragon/os/contracts/factory/DAOFactory')
const EVMScriptRegistryFactory = artifacts.require('@aragon/os/contracts/factory/EVMScriptRegistryFactory')
const ACL = artifacts.require('@aragon/os/contracts/acl/ACL')
const Kernel = artifacts.require('@aragon/os/contracts/kernel/Kernel')


const AragonNFT = artifacts.require('AragonNFT.sol');
const getContract = name => artifacts.require(name)

require('./helpers/setup');

contract('AragonNFT', function ([_, creator, ...accounts]) {

  let MINT_ROLE, BURN_ROLE
  let aragonnftBase, aragonnft

  const name = 'AragonNFT';
  const symbol = 'AragonNFT';
  const firstTokenId = 100;
  const secondTokenId = 200;
  const thirdTokenId = 300;
  const nonExistentTokenId = 999;

  const minter = creator;

  const [
    owner,
    newOwner,
    another,
    anyone,
  ] = accounts;


  before(async () => {
      const kernelBase = await getContract('Kernel').new(true) // petrify immediately
      const aclBase = await getContract('ACL').new()
      const regFact = await getContract('EVMScriptRegistryFactory').new()
      daoFact = await getContract('DAOFactory').new(kernelBase.address, aclBase.address, regFact.address)
      aragonnftBase = await AragonNFT.new({ from: creator });
      // Setup constants
      ANY_ENTITY = await aclBase.ANY_ENTITY()
      APP_MANAGER_ROLE = await kernelBase.APP_MANAGER_ROLE()

      MINT_ROLE = await aragonnftBase.MINT_ROLE()
      BURN_ROLE = await aragonnftBase.BURN_ROLE()
  })

    const newProxyNFT = async () => {
        const r = await daoFact.newDAO(creator)
        const dao = getContract('Kernel').at(r.logs.filter(l => l.event == 'DeployDAO')[0].args.dao)
        const acl = getContract('ACL').at(await dao.acl())

        await acl.createPermission(creator, dao.address, APP_MANAGER_ROLE, creator, { from: creator })

        // nft
        const receipt2 = await dao.newAppInstance('0x5678', aragonnftBase.address, '0x', false, { from: creator })
        const NFTApp = AragonNFT.at(receipt2.logs.filter(l => l.event == 'NewAppProxy')[0].args.proxy)


        await acl.createPermission(ANY_ENTITY, NFTApp.address, MINT_ROLE, minter, { from: creator })
        await acl.createPermission(ANY_ENTITY, NFTApp.address, BURN_ROLE, minter, { from: creator })

        return { dao, NFTApp }
    }

  beforeEach(async function () {
    const { dao, NFTApp } = await newProxyNFT()
    this.aragonnft = NFTApp;
    this.aragonnft.initialize(name, symbol);
  });

  describe('like a Metadata ERC721', function () {
    beforeEach(async function () {
      await this.aragonnft.mint(owner, firstTokenId, { from: minter });
      await this.aragonnft.mint(owner, secondTokenId, { from: minter });
    });

    describe('mint', function () {
      beforeEach(async function () {
        await this.aragonnft.mint(newOwner, thirdTokenId, { from: minter });
      });

      it('adjusts owner tokens by index', async function () {
        (await this.aragonnft.tokenOfOwnerByIndex(newOwner, 0)).toNumber().should.be.equal(thirdTokenId);
      });

      it('adjusts all tokens list', async function () {
        (await this.aragonnft.tokenByIndex(2)).toNumber().should.be.equal(thirdTokenId);
      });
    });

    describe('burn', function () {
      beforeEach(async function () {
        await this.aragonnft.burn(firstTokenId, { from: owner });
      });

      it('removes that token from the token list of the owner', async function () {
        (await this.aragonnft.tokenOfOwnerByIndex(owner, 0)).toNumber().should.be.equal(secondTokenId);
      });

      it('adjusts all tokens list', async function () {
        (await this.aragonnft.tokenByIndex(0)).toNumber().should.be.equal(secondTokenId);
      });

      it('burns all tokens', async function () {
        await this.aragonnft.burn(secondTokenId, { from: owner });
        (await this.aragonnft.totalSupply()).toNumber().should.be.equal(0);
        await shouldFail.reverting(this.aragonnft.tokenByIndex(0));
      });
    });

    describe('metadata', function () {
      const sampleUri = 'mock://mytoken';

      it('has a name', async function () {
        (await this.aragonnft.name()).should.be.equal(name);
      });

      it('has a symbol', async function () {
        (await this.aragonnft.symbol()).should.be.equal(symbol);
      });

      it('sets and returns metadata for a token id', async function () {
        await this.aragonnft.setTokenURI(firstTokenId, sampleUri);
        (await this.aragonnft.tokenURI(firstTokenId)).should.be.equal(sampleUri);
      });

      it('reverts when setting metadata for non existent token id', async function () {
        await shouldFail.reverting(this.aragonnft.setTokenURI(nonExistentTokenId, sampleUri));
      });

      it('can burn token with metadata', async function () {
        await this.aragonnft.setTokenURI(firstTokenId, sampleUri);
        await this.aragonnft.burn(firstTokenId, { from: owner });
        (await this.aragonnft.exists(firstTokenId)).should.equal(false);
      });

      it('returns empty metadata for token', async function () {
        (await this.aragonnft.tokenURI(firstTokenId)).should.be.equal('');
      });

      it('reverts when querying metadata for non existent token id', async function () {
        await shouldFail.reverting(this.aragonnft.tokenURI(nonExistentTokenId));
      });
    });

    describe('tokensOfOwner', function () {
      it('returns total tokens of owner', async function () {
        const tokenIds = await this.aragonnft.tokensOfOwner(owner);
        tokenIds.length.should.equal(2);
        tokenIds[0].should.be.bignumber.equal(firstTokenId);
        tokenIds[1].should.be.bignumber.equal(secondTokenId);
      });
    });

    describe('totalSupply', function () {
      it('returns total token supply', async function () {
        (await this.aragonnft.totalSupply()).should.be.bignumber.equal(2);
      });
    });
  });

  shouldBehaveLikeERC721(creator, creator, accounts);
  
  shouldSupportInterfaces([
    'ERC165',
    'ERC721',
    'ERC721Metadata',
    'ERC721Enumerable',
  ]);
});
