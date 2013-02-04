# Inspired by 
# http://grosser.it/2013/01/17/enqueue-into-sidekiq-via-pure-redis-without-loading-sidekiq
{EventEmitter} = require "events"
util = require 'util'
crypto = require 'crypto'
redis = require 'redis'
_ = require 'underscore'

class CoffeeKiq extends EventEmitter
  constructor: (redis_port, redis_host) ->
    throw new Error 'CoffeeKiq: Init like this: new CoffeeKiq(redis_port, redis_host)' if !redis_port? || !redis_host?
    @redis_port = redis_port
    @redis_host = redis_host
    @connected = false
    @connect()
    
  connect: ->
    @redis_client = redis.createClient @redis_port, @redis_host
    @redis_client.on 'ready', @on_redis_ready
    @redis_client.on 'error', @on_redis_error
    
  perform: (queue, klass, args, options = {}) ->
    if @connected
      if !options.namespace? then namespace = "" else namespace = "#{options.namespace}:"
      if !options.retry? then retry = false else retry = true
      crypto.randomBytes 12, (ex, buf) =>
        payload = JSON.stringify
          queue: queue
          class: klass
          args: args
          jid: buf.toString 'hex'

        @redis_client.sadd(_.compact([namespace, "queues"]).join(":"), queue)
        @redis_client.lpush(_.compact([namespace, "queue", queue]).join(":"), payload)
        @emit 'perform:done'
        return true
    else
      @emit 'perform:error'
      return false
    
  on_redis_ready: =>
    @connected = true
    @emit 'connection:ready'
    
  on_redis_error: =>
    @connected = false
    @emit 'connection:error'
    
  get_secure_random: (callback) ->
    crypto.randomBytes 12, (ex, buf) ->
      callback buf.toString 'hex'
    
exports.CoffeeKiq = CoffeeKiq