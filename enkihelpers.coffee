extend = exports.extend = (object, properties) ->
  for own key, val of properties
    object[key] = val
  return object

exports.merge = (options, overrides) ->
  return extend(extend({}, options), overrides)

generate_id = (bitlength) ->
  bitlength = bitlength || 32
  if bitlength > 32
    parts  = Math.ceil(bitlength / 32)
    string = ''
    while parts--
      string += generate_id(32)
    return string

  limit   = Math.pow(2, bitlength) - 1
  maxSize = limit.toString(36).length
  string  = Math.floor(Math.random() * limit).toString(36)
  
  while string.length < maxSize
    string = '0' + string
  return string

exports.wrap_error = (func, errhandler) ->
  return (args...) ->
    try
      func(args...)
    catch e
      errhandler e

exports.generate_id = generate_id

# faux_counter = 10000

# faux_id = ->
#   faux_counter += 1
#   return '' + faux_counter

# exports.generate_id = faux_id

exports.ReadyQueue = class ReadyQueue
  constructor: ->
    @_queued = []
    @_ready = false
    @_dead = false

  queue: (callback, errback) =>
    @_queued.push( [callback, errback] )

    @process()

  set_ready: =>
    @_ready = true
    @_dead = false
    @process()

  set_dead: =>
    @_ready = false
    @_dead = true
    @process()

  process: =>
    if not ( @_ready or @_dead )
      return
    rev = @_queued.reverse()
    @_queued = []
    while rev.length
      elem = rev.pop()
      if @_ready
        elem[0]?()
      if @_dead
        if elem[1]
          elem[1]()
        else
          throw Error("Call on dead ReadyQueue, but has no Error Handler.")

exports.type_to_string = (obj) ->
  if obj == undefined or obj == null
    return String obj
  classToType = new Object
  for name in "Boolean Number String Function Array Date RegExp".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()
  myClass = Object.prototype.toString.call obj
  if myClass of classToType
    return classToType[myClass]
  return "object"

# if !module.parent
#   x = new ReadyQueue()
#   x.queue(console.log, 'frob', 1)
#   x.queue(console.log, 'bar', 2)
#   x.set_ready()