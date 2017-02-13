_ = require 'lodash'
request = require 'request'

class WorktileClient
  constructor: (options, robot) ->
    @token = options.token
    @robot = robot

  on: (name, callback) ->
    if name is "message"
      #do it by client itself but now use robot for temporary
      @robot.router.post '/worktile/bot/center', (req, res) =>
        message = _.pick req.body, ['user', 'text', 'scope']
        if req.body.token is @token
          callback(message);
        res.send('OK\n');

  send: (scope, text) ->
    options = method: "POST", json: {payload: {scope: scope, text: text}}
    request "http://hook.worktile.com/hubot/#{@token}", options


module.exports = WorktileClient;
