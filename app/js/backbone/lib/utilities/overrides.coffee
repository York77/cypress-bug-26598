@App.module "Utilities.Overrides", (Overrides, App, Backbone, Marionette, $, _) ->

  runnableEmit  = Mocha.Runnable::emit
  runnerEmit    = Mocha.Runner::emit
  uncaught      = Mocha.Runner::uncaught

  _.extend Overrides,
    restore: ->
      Mocha.Runnable::emit   = runnableEmit
      Mocha.Runner::emit     = runnerEmit
      Mocha.Runner::uncaught = uncaught

    overloadMochaRunnableEmit: ->
      ## if app evironment is development we need to list to errors
      ## emitted from all Runnable inherited objects (like hooks)
      ## this makes tracking down Eclectus related App errors much easier
      Mocha.Runnable::emit = _.wrap runnableEmit, (orig, event, err) ->
        switch event
          when "error" then throw err

        orig.call(@, event, err)

    overloadMochaRunnerEmit: ->
      ## uncomment this to see the runner emits
      # Mocha.Runner::emit = _.wrap runnerEmit, (orig, args...) ->
      #   event = args[0]

      #   console.log event

      #   orig.apply(@, args)

    overloadMochaRunnerUncaught: ->
      ## if app environment isnt production we need to listen to
      ## uncaught exceptions (else it makes tracking down bugs hard)
      return if App.config.env("production")

      Mocha.Runner::uncaught = _.wrap uncaught, (orig, err) ->
        ## debugger if this isnt an AssertionError or CypressError or a message err
        ## because that means we prob f'd up something
        if not /(AssertionError|CypressError)/.test(err.name) and not err.__isMessage
          console.error(err.stack)
          debugger

        orig.call(@, err)
