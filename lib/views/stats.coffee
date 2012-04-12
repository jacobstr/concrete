doctype 5
html ->
    head ->
        meta charset: 'utf-8'
        title "#{if @title then @title+' - ' else ''}Concrete"
        meta(name: 'description', content: @desc) if @desc?
        link rel: 'stylesheet', href: 'stylesheets/app.css'
        script src: 'js/jquery-1.6.2.min.js'
        script src: 'js/coffeekup.js'
        script src: 'js/moment.min.js'
        script src: 'http://www.google.com/jsapi', type: 'text/javascript'
        script src: 'stats.js'

    body ->
        header ->
            hgroup ->
                h1 'CONCRETE'
                h2 '.project', -> @project
                nav ->
                    a href: '/', 'Builds'
                    a href: '/stats', class: 'active', 'Stats'
                    form method: 'post', action: '/', ->
                        button '.build', -> 'Build'

        div '#content', ->
          div '#stats', ->
