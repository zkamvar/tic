Stage <- R6Class(
  "Stage",

  public = list(
    initialize = function(name) {
      private$name <- name
    },

    add_step = function(step) {
      self$add_task(run = step$run, check = step$check, prepare = step$prepare)
    },

    add_task = function(run, check = NULL, prepare = NULL) {
      step <- list(
        run = run,
        check = check %||% function() TRUE,
        prepare = prepare %||% function() {}
      )
      private$steps <- c(private$steps, list(step))
      invisible(self)
    },

    reset = function() {
      private$steps <- list()
    },

    prepare_all = function() {
      lapply(private$steps, private$prepare_one)
    },

    run_all = function() {
      lapply(private$steps, private$run_one)
    }
  ),

  private = list(
    name = NULL,
    steps = list(),

    prepare_one = function(step) {
      if (identical(body(step$prepare), body(TicStep$public_methods$prepare)))
        return()

      step_name <- class(step)[[1L]]

      if (!isTRUE(step$check())) {
        message("Skipping prepare: ", step_name)
        print(step$check)
        return()
      }

      message("Preparing: ", step_name)
      step$prepare()

      invisible()
    },

    run_one = function(step) {
      step_name <- class(step)[[1L]]

      if (!isTRUE(step$check())) {
        message("Skipping ", private$name, ": ", step_name)
        print(step$check)
        return()
      }

      message("Running ", private$name, ": ", step_name)
      step$run()
    }
  )
)