import * as funding from './communication-api/ethereum/modules/funding'
import * as project from './communication-api/ethereum/modules/project'

export default {
    ethereum: {
        contracts: {
            ProjectRegistration: require('./smart-contracts/ethereum/build/contracts/ProjectRegistration.json'),
            ProjectTimeline: require('./smart-contracts/ethereum/build/contracts/ProjectTimeline.json'),
            ProjectTimelineProposal: require('./smart-contracts/ethereum/build/contracts/ProjectTimelineProposal.json')
        },
        modules: {
            funding: funding,
            project: project
        }
    }
}