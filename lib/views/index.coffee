doctype 5
html ->
    head ->
        meta charset: 'utf-8'
        title "#{if @title then @title+' - ' else ''}Concrete"
        meta(name: 'description', content: @desc) if @desc?
        link rel: 'stylesheet', href: 'stylesheets/app.css'
        script src: 'js/jquery-1.9.1.min.js'
        script src: 'js/coffeecup.js'
        script src: 'js/moment.min.js'
        script src: 'concrete.js'

    body ->
        header ->
            hgroup ->
                h1 'CONCRETE'
                h2 '.project', -> @project
                nav ->
                    a href: '/', class: 'active', 'Builds'
                    a href: '/stats', 'Stats'
                    form method: 'post', action: '/', ->
                        button '.build', -> 'Build'

        div '#content', ->
            ul '.jobs', ->
                if @jobs.length is 0
                    li '.nojob', -> 'No jobs have been submitted.'
                for i in [@jobs.length - 1..0] by -1
                    @job = @jobs[i]
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

