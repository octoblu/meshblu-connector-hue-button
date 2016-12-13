{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-hue:index')
HueManager      = require './hue-manager'

class Connector extends EventEmitter
  constructor: ->
    @hue = new HueManager
    @hue.on 'change:username', @_onUsernameChange
    @hue.on 'click', @_onClick
    @hue.on 'error', (error) =>
      @emit 'error', error

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    @hue.close callback

  onConfig: (@device={}, callback=->) =>
    { @options, apikey } = device
    debug 'on config', @options
    { ipAddress, apiUsername, sensorName, sensorPollInterval } = @options ? {}
    @hue.connect { ipAddress, apiUsername, sensorName, sensorPollInterval, apikey }, (error) =>
      return callback error if error?
      callback()

  start: (device, callback) =>
    debug 'started'
    @onConfig device, callback

  _onUsernameChange: ({apikey}) =>
    @emit 'update', {apikey}

  _onClick: ({button, state}) =>
    data = {
      action: 'click'
      button
      state
      @device
    }
    @emit 'message', {devices: ['*'], data}

module.exports = Connector
