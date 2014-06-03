process.env.LINDA_BASE  ||= 'http://node-linda-base.herokuapp.com'
process.env.LINDA_SPACE ||= 'iota'

console.log "node-linda-door"

## Linda
LindaClient = require('linda').Client
socket = require('socket.io-client').connect(process.env.LINDA_BASE)
linda = new LindaClient().connect(socket)
ts = linda.tuplespace(process.env.LINDA_SPACE)

linda.io.on 'connect', ->
  console.log "connect!! <#{process.env.LINDA_BASE}/#{ts.name}>"
  last_at = 0

  ## Door Open
  ts.watch {type: 'door', cmd: 'open'}, (err, tuple) ->
    return console.error err if err
    return if tuple.data.response?
    return if last_at + 5000 > Date.now()  # 5sec interval
    last_at = Date.now()
    console.log tuple
    arduino.servoWrite 9, 90
    setTimeout ->
      arduino.servoWrite 9, 10
      setTimeout ->
        arduino.servoWrite 9, 90
      , 1500
      res = tuple.data
      res.response = 'success'
      ts.write res
    , 2000

  ## Door Close
  ts.watch {type: 'door', cmd: 'close'}, (err, tuple) ->
    return if err
    return if tuple.data.response?
    return if last_at + 5000 > Date.now()  # 5sec interval
    last_at = Date.now()
    console.log tuple
    arduino.servoWrite 9, 90
    setTimeout ->
      arduino.servoWrite 9, 170
      setTimeout ->
        arduino.servoWrite 9, 90
      , 1500
      res = tuple.data
      res.response = 'success'
      ts.write res
    , 2000

linda.io.on 'disconnect', ->
  console.log "socket.io disconnect.."


## Arduino
ArduinoFirmata = require('arduino-firmata')
arduino = new ArduinoFirmata().connect(process.env.ARDUINO)

arduino.once 'connect', ->
  console.log "connect!! #{arduino.serialport_name}"
  console.log "board version: #{arduino.boardVersion}"
