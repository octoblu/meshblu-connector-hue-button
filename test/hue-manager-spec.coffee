HueManager = require '../src/hue-manager'

describe 'HueManager', ->
  beforeEach ->
    @sut = new HueManager
    @sut.emit = sinon.spy @sut.emit
    sinon.stub(@sut, '_checkButtons').yields null

  afterEach (done) ->
    @sut.close done

  describe '->connect', ->
    beforeEach (done) ->
      @sut.connect {}, done

    it 'should create a hue connection', ->
      expect(@sut.hue).to.exist

    it 'should update apikey', ->
      apikey =
        devicetype: 'newdeveloper'
      expect(@sut.apikey).to.deep.equal apikey

  context 'with an active client', ->
    beforeEach (done) ->
      options =
        sensorPollInterval: 5
        sensorName: 'tapppy'

      @sut.connect options, (error) =>
        {@hue} = @sut
        @sut._checkButtons.restore()
        @hue.checkButtons = sinon.stub().yields null, state: 'ok', button: 'hi'
        done error
