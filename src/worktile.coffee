{Adapter, TextMessage, Robot, User} = require.main.require('hubot')

_ = require 'lodash'
Client = require './client'

class WorktileBot extends Adapter

  constructor: (@robot, @options) ->
    @client = new Client @options, @robot

  run: =>
    return @robot.logger.error("No service token provided to Hubot") unless this.options.token
    @client.connect @init

  init: (success)=>
    if success
      @robot.logger.info 'Hubot connected worktile'
      @client.on 'message', @message
      @emit('connected')
    else
      @robot.logger.info 'Hubot connecting failed'

  message: (message) =>
    if message.user.role isnt 5
      user = message.user
      user.room = "#{message.scope.ref_type}-#{message.scope.ref_id}"
      text = message.text;

      if message.scope.at
        text = "#{@robot.name} #{text}"
      data = new TextMessage(user, text, 1)
      @robot.receive data

  reply: (envelope, message) =>
    @robot.logger.info "reply #{message} to #{envelope.user.name}"
    if message isnt ''
      data = envelope.user.room.split('-')
      scope = ref_type: data[0], ref_id: data[1], at: envelope.user.id, to: envelope.user
      @client.send scope, message

  send: (envelope, message) =>
    @robot.logger.info "send #{message} to #{envelope.user.name}"
    if message isnt ''
      data = envelope.user.room.split('-')
      scope = ref_type: data[0], ref_id: data[1], at: '', to: envelope.user
      @client.send scope, message


exports.use = (robot) ->
  return new WorktileBot(robot, token: process.env.HUBOT_WORKTILE_TOKEN)

