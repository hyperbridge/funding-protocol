import Project from './communication-api/ethereum/models/Project'
import Contribution from './communication-api/ethereum/models/Contribution'
import Developer from './communication-api/ethereum/models/Developer'
import FundingStorage from './communication-api/ethereum/models/FundingStorage'
import FundingVault from './communication-api/ethereum/models/FundingVault'

export default {
    Ethereum: {
        Contracts: {
            Project: require('./smart-contracts/ethereum/build/Project.json')
        },
        Models: {
            Project: Project,
            Contribution: Contribution,
            Developer: Developer,
            FundingStorage: FundingStorage,
            FundingVault: FundingVault,
        }
    }
}