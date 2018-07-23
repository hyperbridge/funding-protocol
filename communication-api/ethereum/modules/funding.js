import * as abiDecoder from '../lib/abi-decoder'

window.web3 = new window.Web3(new window.Web3.providers.HttpProvider("http://localhost:8545"))

let state = {
    fromAddress: null,
    toAddress: null,
    contracts: {
        FundingStorage: {
            meta: require('../../../smart-contracts/ethereum/build/contracts/FundingStorage.json'),
            address: null
        },
        FundingVault: {
            meta: require('../../../smart-contracts/ethereum/build/contracts/FundingVault.json'),
            address: null
        }
    }
}

export const init = (fromAddress, toAddress) => {
    state.fromAddress = fromAddress
    state.toAddress = toAddress
}

export const setContractAddress = async (contractName, address) => {
    state.contracts[contractName].address = address
}

export const deployContract = async (contractName, params) => {
    const meta = state.contracts[contractName].meta
    const contract = new web3.eth.Contract(meta.abi)

    return await new Promise((resolve) => {
        contract.deploy({
            data: meta.bytecode,
            arguments: params
        }).send({
            from: state.fromAddress,
            gas: 4500000
        }).then((res) => {
            state.contracts[contractName].address = res._address

            resolve(res)
        })

        // .on('confirmation', function(confirmationNumber, receipt){ 
        //     console.log(confirmationNumber); tokencontract.options.address =
        //         receipt.contractAddress;
        // }).on('receipt', function (receipt)
        // { console.log(receipt) })
    })
}

export const call = async (contractName, methodName, params) => {
    console.log('Calling ' + contractName + '.' + methodName + ' with params: ', params)

    if (contractName === 'test' && methodName === 'test') {

    } else {
        return await new Promise((resolve) => {
            const data = state.contracts[contractName].methods[methodName]
                .apply(null, params)
                .call({ from: state.fromAddress, gas: 3000000 }, (err, res) => {
                    if (err) throw err
                    resolve(res)
                })
        })
    }
}