import * as truffleContract from 'truffle-contract'
import * as abiDecoder from '../lib/abi-decoder'

const provider = new window.Web3.providers.HttpProvider("http://localhost:8545")

window.web3 = new window.Web3(provider)


export let state = {
    fromAddress: null,
    toAddress: null,
    contracts: {
        FundingStorage: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/FundingStorage.json'),
            address: null
        },
        DeveloperStorageAccess: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/DeveloperStorageAccess.json'),
            address: null
        },
        ProjectStorageAccess: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectStorageAccess.json'),
            address: null
        },
        ContributionStorageAccess: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ContributionStorageAccess.json'),
            address: null
        },
        FundingVault: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/FundingVault.json'),
            address: null
        },
        Developer: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/Developer.json'),
            address: null,
            links: [
                {
                    name: 'DeveloperStorageAccess', address: null
                }
            ]
        },
        Contribution: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/Contribution.json'),
            address: null,
            links: [
                {
                    name: 'ContributionStorageAccess', address: null
                },
                {
                    name: 'ProjectStorageAccess', address: null
                }
            ]
        },
        ProjectBase: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectBase.json'),
            address: null,
            links: [
                {
                    name: 'ProjectStorageAccess', address: null
                },
                {
                    name: 'DeveloperStorageAccess', address: null
                },
                {
                    name: 'ContributionStorageAccess', address: null
                }
            ]
        },
        ProjectTimeline: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectTimeline.json'),
            address: null
        },
        ProjectTimelineHelpersLibrary: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectTimelineHelpersLibrary.json'),
            address: null,
            links: [
                {
                    name: 'ProjectStorageAccess', address: null
                }
            ]
        },
        ProjectTimelineProposal: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectTimelineProposal.json'),
            address: null,
            links: [
                {
                    name: 'ProjectTimelineHelpersLibrary', address: null
                }
            ]
        },
        ProjectContributionTierHelpersLibrary: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectContributionTierHelpersLibrary.json'),
            address: null,
            links: [
                {
                    name: 'ProjectStorageAccess', address: null
                }
            ]
        },
        ProjectMilestoneCompletion: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectMilestoneCompletion.json'),
            address: null,
            links: [
                {
                    name: 'ProjectTimelineHelpersLibrary', address: null
                }
            ]
        },
        ProjectRegistration: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/ProjectRegistration.json'),
            address: null,
            links: [
                {
                    name: 'ProjectTimelineHelpersLibrary', address: null
                },
                {
                    name: 'ProjectContributionTierHelpersLibrary', address: null
                }
            ]
        },
        CurationStorageAccess: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/CurationStorageAccess.json'),
            address: null
        },
        Curation: {
            contract: null,
            deployed: null,
            meta: require('../../../smart-contracts/ethereum/build/contracts/Curation.json'),
            address: null,
            links: [
                {
                    name: 'CurationStorageAccess', address: null
                },
                {
                    name: 'ProjectStorageAccess', address: null
                }
            ]
        },
    }
}

const buildContract = (meta, options) => {
    const contract = truffleContract(meta)
    contract.setProvider(provider)

    contract.defaults({
        from: options.from,
        gas: options.gas
    })

    contract.setNetwork('*')

    // dirty hack for web3@1.0.0 support for localhost testrpc, see https://github.com/trufflesuite/truffle-contract/issues/56#issuecomment-331084530
    if (typeof contract.currentProvider.sendAsync !== 'function') {
        contract.currentProvider.sendAsync = function () {
            return contract.currentProvider.send.apply(contract.currentProvider, arguments)
        }
    }

    return contract
}

export const init = (fromAddress, toAddress) => {
    state.fromAddress = fromAddress
    state.toAddress = toAddress
}

export const setContractAddress = async (contractName, address) => {
    console.log('[FundingProtocol] Setting contract address for: ' + contractName + ' to ' + address)

    return await new Promise((resolve, reject) => {
        const contract = state.contracts[contractName].contract = buildContract(state.contracts[contractName].meta, {
            from: state.fromAddress,
            gas: 6500000
        })

        contract.at(address).then((deployed) => {
            state.contracts[contractName].deployed = deployed
            state.contracts[contractName].address = deployed.address

            resolve(deployed)
        }).catch(reject)
    })

    // const meta = state.contracts[contractName].meta
    // const contract = new web3.eth.Contract(meta.abi, address, {
    //     from: state.fromAddress,
    //     gas: 6500000
    // })

    // state.contracts[contractName].deployed = contract
    // state.contracts[contractName].deployed._address = address
    // state.contracts[contractName].deployed.options.address = address
}


// await deployer.deploy(FundingStorage);
// const fs = await FundingStorage.deployed();

// await deployer.deploy(ProjectStorageAccess);
// await deployer.link(ProjectStorageAccess, [ProjectBase, ProjectTimelineHelpersLibrary, ProjectContributionTierHelpersLibrary, Contribution, Curation]);

// await deployer.deploy(DeveloperStorageAccess);
// await deployer.link(DeveloperStorageAccess, [Developer, ProjectBase]);

// await deployer.deploy(ContributionStorageAccess);
// await deployer.link(ContributionStorageAccess, [Contribution, ProjectBase]);

// await deployer.deploy(CurationStorageAccess);
// await deployer.link(CurationStorageAccess, Curation);

// await deployer.deploy(ProjectTimelineHelpersLibrary);
// await deployer.link(ProjectTimelineHelpersLibrary, [ProjectTimelineProposal, ProjectRegistration, ProjectMilestoneCompletion]);

// await deployer.deploy(ProjectContributionTierHelpersLibrary);
// await deployer.link(ProjectContributionTierHelpersLibrary, ProjectRegistration);

// await deployer.deploy(ProjectRegistration, fs.address);
// await deployer.deploy(ProjectTimeline, fs.address);
// await deployer.deploy(ProjectContributionTier, fs.address);
// await deployer.deploy(ProjectMilestoneCompletion, fs.address);
// await deployer.deploy(ProjectTimelineProposal, fs.address);

// await deployer.deploy(Developer, fs.address);
// await deployer.deploy(Contribution, fs.address);
// await deployer.deploy(Curation, fs.address);



export const deployContract = async (contractName, links, params) => {
    console.log('[FundingProtocol] Deploying contract for: ' + contractName)

    const contract = state.contracts[contractName].contract = buildContract(state.contracts[contractName].meta, {
        from: state.fromAddress,
        gas: 6500000
    })

    if (!links) {
        links = []
    }

    //let data = meta.bytecode

    for (let i in links) {
        let link = links[i]

        contract.link(link.name, link.address)

        //data = data.replace(new RegExp('__' + link.name + '_+', 'g'), link.address.replace('0x', ''))
    }

    return await new Promise((resolve) => {
        contract.new.apply(null, params).then((deployed) => {
            state.contracts[contractName].deployed = deployed

            resolve(deployed)
        })

        // contract.deploy({
        //     data: data,
        //     arguments: params
        // }).send({
        //     from: state.fromAddress,
        //     gas: 6500000
        // }).then((res) => {
        //     state.contracts[contractName].deployed = contract
        //     state.contracts[contractName].deployed._address = res._address
        //     state.contracts[contractName].deployed.options.address = res._address

        //     resolve(res)
        // })
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