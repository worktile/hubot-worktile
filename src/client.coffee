_ = require 'lodash'
request = require 'request'

class WorktileClient
  constructor: (options, robot) ->
    @token = options.token
    @robot = robot
    @url = "https://hook.worktile.com/hubot/#{@token}"

  connect: init ->
    @robot.http(url).post({}) (err, res, body) =>
      init() unless body.code isnt 200

  on: (name, cb) ->
    if name is "message"
      @robot.router.post '/worktile/bot/center', (req, res) =>
        cb(req.body) unless req.body.token isnt @token
        res.send('OK\n');

  send: (scope, text) ->
    options = method: 'POST', json: {payload: {scope: scope, text: text}}
    request @url, options


module.exports = WorktileClient;
