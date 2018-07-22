import * as abiDecoder from '../lib/abi-decoder'

window.web3 = new window.Web3(new window.Web3.providers.HttpProvider("http://localhost:8545"))

let state = {
    fromAddress: null,
    toAddress: null,
    contracts: {
        Contribution: {
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/Contribution.json'),
            address: null
        },
        Developer: {
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/Developer.json'),
            address: null
        },
        FundingStorage: {
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/FundingStorage.json'),
            address: null
        },
        FundingVault: {
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/FundingVault.json'),
            address: null
        },
        ProjectRegistration: {
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectRegistration.json'),
            address: null
        },
        ProjectTimeline: {
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectTimeline.json'),
            address: null
        },
        ProjectTimelineProposal: {
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectTimelineProposal.json'),
            address: null
        }
    }
}

export const init = (fromAddress, toAddress) => {
    state.fromAddress = fromAddress
    state.toAddress = toAddress
}

export const setContractAddress = (contractName, address) => {
    const meta = state.contracts[contractName].meta
    const contract = new web3.eth.Contract(meta.abi, address, {
        from: state.fromAddress,
        gas: 6500000
    })

    contract.options.address = address

    state.contracts[contractName].deployed = contract
    state.contracts[contractName].deployed._address = address
    state.contracts[contractName].deployed.options.address = address
}

export const deployContract = async (contractName, params) => {
    const meta = state.contracts[contractName].meta
    const contract = new web3.eth.Contract(meta.abi)

    return await new Promise((resolve) => {
        contract.deploy({
            data: meta.bytecode.replace(/__ProjectHelpersLibrary_________________/g, web3.utils.fromAscii('__ProjectHelpersLibrary_________________').replace('0x', '')),
            arguments: params
        }).send({
            from: state.fromAddress,
            gas: 6500000
        }).then((res) => {
            state.contracts[contractName].deployed = contract
            state.contracts[contractName].deployed._address = res._address
            state.contracts[contractName].deployed.options.address = res._address

            resolve(res)
        })
    })
}

export const call = async (contractName, methodName, params) => {
    console.log('Calling ' + contractName + '.' + methodName + ' with params: ', params)

    if (contractName === 'test' && methodName === 'test') {

    } else {
        return await new Promise((resolve) => {
            const data = state.contracts[contractName].deployed.methods[methodName]
                .apply(null, params)
                .call({ from: state.fromAddress, gas: 3000000 }, (err, res) => {
                    if (err) throw err
                    resolve(res)
                })
        })
    }
}



// export const createProject = async (title, description, about, contributionGoal, noRefunds, noTimeline) => {
//     console.log('Calling Project.createProject with arguments: ', arguments)

//     return await new Promise((resolve) => {
//         const data = state.contracts.ProjectRegistration.methods
//             .createProject(title, description, about, contributionGoal, noRefunds, noTimeline)
//             .call({ from: state.fromAddress, gas: 3000000 }, (err, res) => {
//                 if (err) throw err
//                 resolve(res)
//             })
//     })
// }

// export const getProject = async (id) => {
//     console.log('Calling Project.getProject with arguments: ', arguments)

//     return await new Promise((resolve) => {
//         const data = state.contracts.ProjectRegistration.methods
//             .getProject(id)
//             .call({ from: state.fromAddress, gas: 3000000 }, (err, res) => {
//                 if (err) throw err
//                 resolve(res)
//             })
//     })
// }

// export const getTimelineMilestone = async (projectId, milestoneId) => {
//     console.log('Calling Project.getTimelineMilestone with arguments: ', arguments)

//     return await new Promise((resolve) => {
//         const data = state.contracts.ProjectRegistration.methods
//             .getTimelineMilestone(projectId, milestoneId)
//             .call({ from: state.fromAddress, gas: 3000000 }, (err, res) => {
//                 if (err) throw err
//                 resolve(res)
//             })
//     })
// }

// export const submitMilestoneCompletion = async (_projectId, _report) => {

// }