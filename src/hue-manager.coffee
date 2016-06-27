_              = require 'lodash'
HueUtil        = require 'hue-util'
{EventEmitter} = require 'events'
tinycolor      = require 'tinycolor2'
debug          = require('debug')('meshblu-connector-hue:hue-manager')

class HueManager extends EventEmitter
  connect: ({@ipAddress, @apiUsername, @sensorName, @sensorPollInterval, @apikey}, callback) =>
    @_emit = _.throttle @emit, 500, {leading: true, trailing: false}
    @apikey ?= {}
    {username} = @apikey
    @apiUsername ?= 'newdeveloper'
    @apikey.devicetype = @apiUsername
    @hue = new HueUtil @apiUsername, @ipAddress, username, @_onUsernameChange
    @_setInitialState (error) =>
      return callback error if error?
      @_createPollInterval()
      callback()

  close: (callback) =>
    clearInterval @pollInterval
    callback()

  _checkButtons: (callback) =>
    @hue.checkButtons @sensorName, (error, result) =>
      console.error error if error?
      return callback error if error?
      callback null, result

  _createPollInterval: =>
    clearInterval @pollInterval
    @pollInterval = setInterval @_pollSensor, @sensorPollInterval if @sensorPollInterval?

  _onUsernameChange: (username) =>
    return if username == @apikey.username
    @apikey.username = username
    @_emit 'change:username', {@apikey}

  _pollSensor: (callback=->) =>
    @_checkButtons (error, result) =>
      return callback error if error?
      {state, button} = result ? {}
      return callback() if _.isEqual result, @previousResult
      @previousResult = result
      @_emit 'click', {button, state}

  _setInitialState: (callback) =>
    @_checkButtons (error, result) =>
      return callback error if error?
      @previousResult = result
      callback()

module.exports = HueManager
