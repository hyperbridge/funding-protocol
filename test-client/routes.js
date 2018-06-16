const routes = require('next-routes')()

routes
    .add('/', '/index')
    .add('/developers/new', '/developers/new')
    .add('/projects/new', '/projects/new')
    .add('/developers/:id', '/developers/show')
    .add('/projects/:id', '/projects/show')
    .add('/bounties', '/bounties/showBounties')

module.exports = routes
