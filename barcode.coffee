process.env.LINDA_BASE  ||= 'http://node-linda-base.herokuapp.com'
process.env.LINDA_SPACE ||= 'iota'

# ARGV

argv = require('optimist')
  .demand(['u','p'])
  .alias('u', 'user')
  .alias('p', ['pass','password'])
  .describe('u', 'username for gyazz.com/増井研')
  .describe('p', 'password for gyazz.com/増井研')
  .argv

# LINDA
LindaClient = require('linda-socket.io').Client
socket      = require('socket.io-client').connect(process.env.LINDA_BASE)
request     = require 'request'


linda = new LindaClient().connect(socket)
ts = linda.tuplespace process.env.LINDA_SPACE

linda.io.on 'connect',->
  console.log "connect linda"

  process.stdin.setEncoding('utf8')
  process.stdin.on 'readable', ()->
    input = process.stdin.read()
    return unless input

    input = input.split("\n")[0]
    console.log "INPUT:#{input}"

    request.get "http://gyazz.com/増井研/イオタ411入室バーコードシステム/text",
      auth:
        user:argv.u
        pass:argv.p
    ,(err,response,body)->
      return console.error err if err
      return console.error response unless response.statusCode is 200

      numbers = body.split("\n")
      console.log numbers

      for number in numbers
        return writeOpenTuple() if number.match input

      return console.log "NOT FOUND"

  writeOpenTuple = ->
    console.log "DOOR OPEN"
    ts.write
      type:"door"
      cmd:"open"


