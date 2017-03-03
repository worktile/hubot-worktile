_ = require 'lodash'
request = require 'request'
io = require 'socket.io-client'

class WorktileClient
  constructor: (options, robot) ->
    @token = options.token
    @robot = robot
    @url = "http://worktile.local:8300/hubot/#{@token}"
    @im = "http://lesschat.win:8800/message"

  connect: (init) ->
    @robot.http(@url).post({}) (err, res, body) =>
      try
        @identifier = JSON.parse(body)
        init(@identifier.token && @identifier.uid)
      catch err
        init(false)

  on: (name, cb) ->
    if name is "message"
      @robot.router.post '/worktile/bot/center', (req, res) =>
        cb(req.body) unless req.body.token isnt @token
        res.send('OK\n');
      @robot.logger.info 'Hubot connected worktile with HTTP mode'

      socket = io @im, {
        query: "token=#{@identifier.token}&uid=#{@identifier.uid}&client=hubot",
        transports: ['websocket']
      }
      socket.on 'connect', => @robot.logger.info 'Hubot connected worktile with RTM mode'
      socket.on 'service', (data) => cb(data)

  send: (scope, text) ->
    options = method: 'POST', json: {payload: {scope: scope, text: text}}
    request @url, options

module.exports = WorktileClient
