
# superclass for storing results of a verification activity
setRefClass("confrontation"
  ,fields = list(
      call  = "call"  # (user's) call that generated the object
    , value = "list"  # results of confrontation 
    , calls = "list"  # calls executed during confrontation
    , warn  = "list"  # list of 'warning' objects
    , error = "list"  # list of 'error' objects
  )
  , methods=list(
    show = function() .show_confrontation(.self)
  )
)

.show_confrontation <- function(.self){
  cat(sprintf("Reference object of class '%s'\n",class(.self)))
  cat(sprintf('Confrontations: %d\n', length(.self$calls)))
  cat(sprintf('Warnings      : %d\n',sum(sapply(.self$warn,function(w)!is.null(w)))))
  cat(sprintf('Errors        : %d\n',sum(sapply(.self$error,function(w)!is.null(w)))))
}


# confront data with a subclass of 'validator'
setGeneric("confront",
  def = function(x, y, ...) standardGeneric("confront")
)

setClassUnion('data',c("data.frame","list","environment"))

# confront a verifier with a (set of) data set(s)
setMethod("confront",signature("verifier","data"), function(x,y,...){
  L <- lapply(x$calls,factory(eval), y)
  new('confrontation',
      call = match.call()
      , calls = x$calls
      , value = lapply(L,"[[",1)
      , warn  = lapply(L,"[[",2)
      , error = lapply(L,"[[",3)     
  )
})


# indicators serve a different purpose than validations.
setRefClass("indicatorValue", contains = "confrontation")

setMethod("confront",signature("indicator","data"),function(x,y,...){
  L <- lapply(x$calls,factory(eval), y)
  new('indicatorValue',
      call = match.call()
      , calls = x$calls
      , value = lapply(L,"[[",1)
      , warn =  lapply(L,"[[",2)
      , error = lapply(L,"[[",3)     
  )  
})

# indicators serve a different purpose than validations.
setRefClass("validatorValue", contains = "confrontation"
  fields = list(
      , impact     = "list" # impact of mismatch on data
      , severity   = "list" # amount of mismatch between actual and desired score
    )
)

setMethod("confront",signature("validator","data"),
  function(x, y
    , impact=c("none","Lp","rspa","FH")
    , severity=c("none","Lp","gower")
    , p=c(impact=2,severity=1), ...)
  {
    
    L <- lapply(x$calls,factory(eval), y)
    new('validatorValue',
        call = match.call()
        , calls = x$calls
        , value = lapply(L,"[[",1)
        , warn =  lapply(L,"[[",2)
        , error = lapply(L,"[[",3)     
    )
  }
)





