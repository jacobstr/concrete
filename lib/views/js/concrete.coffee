$ ->
    addClick = (job)->
        $(job).click (event)->
            alreadyOpened = $(event.currentTarget).find('div.job_container').hasClass 'open'
            closeAll()
            if not alreadyOpened
                $(event.currentTarget).find('div.job_container').slideDown 'fast'
                $(event.currentTarget).find('div.job_container').addClass 'open'
            return false

    updateJob = (job)->
        id = $(job).find('.job_id').first().html()
        $.get "/job/#{id}", (data)->
            $(job).find('.job_container').first().html(data.log)
            if data.finished
                $(job).find('a img.loader').remove()
                $(coffeecup.render outcomeTemplate, job: data).insertBefore $(job).find('.job_id')
                $('button.build').show()
                return false
            setTimeout ->
                updateJob job
            , 1000
        , 'json'

    outcomeTemplate = ->
        outcomeClass = if @job.failed then '.failure' else '.success'
        div ".outcome#{outcomeClass}", ->
            if @job.failed then '&#10008;&nbsp;failure' else '&#10003;&nbsp;success'

    jobTemplate = ->
        li '.job', ->
            d = moment(@job.addedTime)
            day_time = d.calendar().split(' at ')
            div '.day', -> "#{day_time[0]}"
            a href: "/job/#{@job._id.toString()}", ->
                div '.time', -> "#{day_time[1]}"
                if commit=@job.commit
                    div '.commit_details', ->
                        span '.commit-sha', -> ''+commit.sha+' '
                        span '.commit-message', -> commit.message
                        span '.commit-time', -> " ("+moment(commit.time).fromNow()+")"
                img '.loader', src:'images/spinner.gif'
                div '.job_id', -> "#{@job._id.toString()}"
            div '.job_container', ->
                @job.log

    closeAll = ->
        opened = $('li.job').find 'div.job_container.open'
        for container in opened
            $(container).slideUp 'fast'
            $(container).removeClass 'open'

    $('button.build').click (event) ->
        closeAll()
        $('button.build').hide()
        $('li.nojob').hide()
        $.post '/', (data) ->
            if $('ul.jobs').find('li.nojob').length > 0
               $('ul.jobs').find('li.nojob').first().remove()
            job = $('ul.jobs').prepend coffeecup.render jobTemplate, job: data
            job = $(job).find('li').first()
            addClick job
            updateJob job
            hideDuplicateMonthTags()
            $(job).find('.job_container').click()
        , 'json'
        return false

    $('li.job').each (iterator, job)->
        addClick job

    #Hide duplicate date strings
    hideDuplicateMonthTags = ->
      lastText = ''
      $('.day').each (iterator,dateDiv) ->
        $dateDiv = $ dateDiv
        if lastText == $dateDiv.text()
          $dateDiv.hide()
        else
          lastText = $dateDiv.text()
    hideDuplicateMonthTags()
  
