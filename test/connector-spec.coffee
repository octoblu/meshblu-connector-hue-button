Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @sut = new Connector
    {@hue} = @sut
    @hue.connect = sinon.stub().yields null
    @sut.start {}, done

  afterEach (done) ->
    @sut.close done

  it 'should call connect', ->
    expect(@hue.connect).to.have.been.called

  describe 'on change:username', ->
    beforeEach ->
      @sut.emit = sinon.stub()
      apikey =
        some: 'thing'

      @hue.emit 'change:username', {apikey}

    it 'should emit update', ->
      apikey =
        some: 'thing'
      expect(@sut.emit).to.have.been.calledWith 'update', {apikey}

  describe 'on click', ->
    beforeEach ->
      @sut.emit = sinon.stub()
      @hue.emit 'click', button: 'tapppy', state: 'arizona'

    it 'should emit update', ->
      data =
        action: 'click'
        button: 'tapppy'
        state: 'arizona'
      expect(@sut.emit).to.have.been.calledWith 'message', {devices: ['*'], data}

  describe '->isOnline', ->
    it 'should yield running true', (done) ->
      @sut.isOnline (error, response) =>
        return done error if error?
        expect(response.running).to.be.true
        done()

  describe '->onConfig', ->
    beforeEach (done) ->
