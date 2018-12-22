const shouldFail = require('./helpers/shouldFail');
const { shouldBehaveLikeERC721 } = require('./ERC721.behavior');
const { shouldSupportInterfaces } = require('./SupportsInterface.behavior');


const AragonNFT = artifacts.require('AragonNFT.sol');

require('./helpers/setup');

contract('AragonNFT', function ([_, creator, ...accounts]) {

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

  beforeEach(async function () {
    this.token = await AragonNFT.new({ from: creator });
    this.token.initialize(name, symbol);
  });

  describe('like a Metadata ERC721', function () {
    beforeEach(async function () {
      await this.token.mint(owner, firstTokenId, { from: minter });
      await this.token.mint(owner, secondTokenId, { from: minter });
    });

    describe('mint', function () {
      beforeEach(async function () {
        await this.token.mint(newOwner, thirdTokenId, { from: minter });
      });

      it('adjusts owner tokens by index', async function () {
        (await this.token.tokenOfOwnerByIndex(newOwner, 0)).toNumber().should.be.equal(thirdTokenId);
      });

      it('adjusts all tokens list', async function () {
        (await this.token.tokenByIndex(2)).toNumber().should.be.equal(thirdTokenId);
      });
    });

    describe('burn', function () {
      beforeEach(async function () {
        await this.token.burn(firstTokenId, { from: owner });
      });

      it('removes that token from the token list of the owner', async function () {
        (await this.token.tokenOfOwnerByIndex(owner, 0)).toNumber().should.be.equal(secondTokenId);
      });

      it('adjusts all tokens list', async function () {
        (await this.token.tokenByIndex(0)).toNumber().should.be.equal(secondTokenId);
      });

      it('burns all tokens', async function () {
        await this.token.burn(secondTokenId, { from: owner });
        (await this.token.totalSupply()).toNumber().should.be.equal(0);
        await shouldFail.reverting(this.token.tokenByIndex(0));
      });
    });

    describe('metadata', function () {
      const sampleUri = 'mock://mytoken';

      it('has a name', async function () {
        (await this.token.name()).should.be.equal(name);
      });

      it('has a symbol', async function () {
        (await this.token.symbol()).should.be.equal(symbol);
      });

      it('sets and returns metadata for a token id', async function () {
        await this.token.setTokenURI(firstTokenId, sampleUri);
        (await this.token.tokenURI(firstTokenId)).should.be.equal(sampleUri);
      });

      it('reverts when setting metadata for non existent token id', async function () {
        await shouldFail.reverting(this.token.setTokenURI(nonExistentTokenId, sampleUri));
      });

      it('can burn token with metadata', async function () {
        await this.token.setTokenURI(firstTokenId, sampleUri);
        await this.token.burn(firstTokenId, { from: owner });
        (await this.token.exists(firstTokenId)).should.equal(false);
      });

      it('returns empty metadata for token', async function () {
        (await this.token.tokenURI(firstTokenId)).should.be.equal('');
      });

      it('reverts when querying metadata for non existent token id', async function () {
        await shouldFail.reverting(this.token.tokenURI(nonExistentTokenId));
      });
    });

    describe('tokensOfOwner', function () {
      it('returns total tokens of owner', async function () {
        const tokenIds = await this.token.tokensOfOwner(owner);
        tokenIds.length.should.equal(2);
        tokenIds[0].should.be.bignumber.equal(firstTokenId);
        tokenIds[1].should.be.bignumber.equal(secondTokenId);
      });
    });

    describe('totalSupply', function () {
      it('returns total token supply', async function () {
        (await this.token.totalSupply()).should.be.bignumber.equal(2);
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
