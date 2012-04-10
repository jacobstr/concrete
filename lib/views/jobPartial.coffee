li '.job', ->
    d = @moment(@job.addedTime)
    day_time = d.calendar().split(' at ')
    div '.day', -> "#{day_time[0]}"
    a href: "/job/#{@job._id.toString()}", ->
        div '.time', -> "#{day_time[1]}"
        if commit=@job.commit
            div '.commit_details', ->
                span '.commit-sha', -> ''+commit.sha+' '
                span '.commit-message', -> commit.message
                span '.commit-time', -> " ("+@moment(commit.time).fromNow()+")"

        if @job.finished
            outcomeClass = if @job.failed then '.failure' else '.success'
            div ".outcome#{outcomeClass}", ->
                if @job.failed then '&#10008;&nbsp;failure' else '&#10003;&nbsp;success'
        div '.job_id', -> "#{@job._id.toString()}"
    div '.job_container', ->
        @job.log
