import * as abiDecoder from '../lib/abi-decoder'


window.web3 = new window.Web3(new window.Web3.providers.HttpProvider("http://localhost:8545"))


class Contribution {
    constructor() {
    }

    init(contractMeta, contractAddress, fromAddress, toAddress) {
        console.log("Initializing Funding contract", arguments)

        //web3.setProvider(new web3.providers.HttpProvider("https://ropsten.infura.io/XXXXXX"))
        this.contractMeta = contractMeta
        this.contractAddress = contractAddress
        this.fromAddress = fromAddress
        this.toAddress = toAddress
        this.nonce = 0
        this.contract = new web3.eth.Contract(this.contractMeta.abi, this.contractAddress)
    }

    async getContribution(id) {
        console.log('Calling Funding.getContribution with arguments: ', arguments)

        return await new Promise((resolve) => {
            const data = this.contract.methods
                .getLatestVersion(id)
                .call({ from: this.fromAddress, gas: 3000000 }, (err, res) => {
                    if (err) throw err
                    resolve(res)
                })
        })
    }

    getBalance() {
        return 0
    }
}

export default new Contribution()