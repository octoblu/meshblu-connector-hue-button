{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-hue-button:index')
_               = require 'lodash'
HueUtil         = require 'hue-util'

class HueButton extends EventEmitter
  constructor: ->
    debug 'HueButton constructed'
    @options = {}

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onMessage: (message) =>
    debug 'on message', message

  onConfig: (device={}) =>
    debug 'on config', apikey: device.apikey
    @apikey = device.apikey || {}
    @setOptions device.options

  setOptions: (options={}) =>
    debug 'setOptions', options
    defaults = apiUsername: 'octoblu', sensorPollInterval: 5000
    @options = _.extend defaults, options

    if @options.apiUsername != @apikey?.devicetype
      @apikey =
        devicetype: @options.apiUsername
        username: null

    @hue = new HueUtil @options.apiUsername, @options.ipAddress, @apikey?.username, @onUsernameChange

    clearInterval @pollInterval
    @pollInterval = setInterval @checkSensors, @options.sensorPollInterval

  onUsernameChange: (username) =>
    debug 'onUsernameChange', username
    @apikey.username = username
    @emit 'update', apikey: @apikey

  checkSensors: =>
    debug 'checking sensors'
    @hue.checkButtons @options.sensorName, (error, response) =>
      return console.error error if error?
      return if _.isEqual @lastState, response.state
      @lastState = response.state
      @emit 'message', devices: ['*'], topic: 'click', data: button: response.button

  start: (device) =>
    { @uuid } = device
    debug 'started', @uuid
    @onConfig device

module.exports = HueButton
