define ['angular', 'underscore'], (angular, _) ->
  angular.module('baobab.directive.autocomplete', [])

  .directive 'autocomplete', ($compile) ->
    restrict: 'A'
    scope:
      "results": "="
      "autocomplete": "="
      "target": "="
    template: (elem, attr) ->
      '<div><span ng-repeat="tag in target track by $index" class="tag" ' +
      'ng-include="\'/partials/tag.html\'"></span><span ' +
      'class="tag-wrap-input" ng-transclude/></div>'
    transclude: 'element'
    replace: true
    link: (scope, elem, attr) ->
      elem.addClass('autocomplete')
      input = elem.find('[autocomplete]')

      results =
        completions: []
        selection: null
        index: 0

      # Place completions in scope
      scope.results = results

      # Set the width proportionally to the element
      span = document.createElement("span")
      setWidth = () ->
        content = input.val() || ""
        span.textContent = content
        span.style.visibility = "hidden"
        span.style.position = "absolute"
        input.after(span)
        span.style.left = input[0].offsetLeft + input[0].clientLeft + 1 + "px"
        span.style.top = input[0].offsetTop + input[0].clientTop + 1 + "px"
        input.css("width", 20 + span.offsetWidth + "px")
        span.remove()

      AutocompleteException = (message) ->
        @name = "AutocompleteException"
        @message = message

      # Retrieve options
      scope.$watch 'autocomplete', _.once (options) ->
        if !options
          throw
            new AutocompleteException "" +
              "Could not retrieve options while configuring autocomplete"
        if !options.complete
          throw
            new AutocompleteException "" +
              "No completion function provided to autocomplete"
        if !options.parse
          throw
            new AutocompleteException "No parse provided in autocomplete model"
        complete = options.complete
        parse = options.parse

        updateCompletions = () ->
          setWidth()
          results.completions = complete(input.val())
          results.index = results.completions.indexOf(results.selection)
          if results.index < 0
            results.index = 0
          results.selection = results.completions[results.index] || null

        selectCompletion = () ->
          return if _.isEmpty(results.selection)
          model = scope.target
          if !model
            console.log "WARN: No model on selectCompletion"
            return
          model.push(results.selection)
          input.val("")
          updateCompletions()

        removeTag = () ->
          model = scope.target
          if !model
            console.log "WARN: No model on removeTag"
            return
          model.pop()

        updateIndex = (f) ->
          scope.$apply () ->
            results.index = f(results.index)
            if (results.index >= 0)
              results.selection = results.completions[results.index]
            else
              results.selection = null

        input.on 'input', (event) ->
          val = input.val()
          if val.indexOf(",") >= 0
            val = _.map val.split(","), (text) ->
              text.replace(///[ ]*$///, '').replace(/^ */, '')
            last = _.last(val)
            val = _.map(_.compact(_.initial(val)), parse)

            scope.$apply () ->
              model = scope.target
              if !model
                console.log "WARN: No model on comma completion"
                return
              _.map val, (contact) ->
                model.push(contact)
              input.val(last)
              setWidth()
              updateCompletions()
          else
            scope.$apply updateCompletions

        input.on 'blur', (event) ->
          val = input.val()
          val = _.map val.split(","), (text) ->
            text.replace(///[ ]*$///, '').replace(/^ */, '')
          val = _.map(_.compact(val), parse)

          scope.$apply () ->
            model = scope.target
            if !model
              console.log "WARN: No model on blur"
              return
            _.map val, (contact) ->
              model.push(contact)
            input.val("")
            setWidth()
            updateCompletions()

        keys =
            13: (event) -> #enter
              return true if _.isEmpty(results.completions)
              return true if _.isEmpty(results.selection)
              scope.$apply selectCompletion #enter
              event.preventDefault()
            39: (event) -> #right
              return true if _.isEmpty(results.completions)
              return true if _.isEmpty(results.selection)
              scope.$apply selectCompletion #right
              event.preventDefault()
            9: (event) -> #tab
              return true if _.isEmpty(results.completions)
              return true if _.isEmpty(results.selection)
              scope.$apply selectCompletion
              event.preventDefault()
            38: (event) -> #up
              updateIndex (i) -> Math.max(i - 1, -1)
              event.preventDefault()
            40: (event) -> #down
              updateIndex (i) -> Math.min(i + 1, results.completions.length - 1)
              event.preventDefault()
            8: (event) -> #backspace
              if input.val() == ""
                scope.$apply removeTag
                event.preventDefault()

        input.on 'keydown', (event) ->
          return true if !keys[event.which]
          keys[event.which](event)
