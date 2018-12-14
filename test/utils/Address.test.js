const AddressImpl = artifacts.require('AddressImpl');
const ERC165Mock = artifacts.require('ERC165Mock');

require('../helpers/setup');

contract('Address', function ([_, anyone]) {
  beforeEach(async function () {
    this.mock = await AddressImpl.new();
  });

  it('should return false for account address', async function () {
    (await this.mock.isContract(anyone)).should.equal(false);
  });

  it('should return true for contract address', async function () {
    const contract = await ERC165Mock.new();
    (await this.mock.isContract(contract.address)).should.equal(true);
  });
});
