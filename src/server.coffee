express = require 'express'
stylus = require 'stylus'
fs = require 'fs'
path = require 'path'
runner = require './runner'
jobs = require './jobs'
git = require './git'
moment = require 'moment'
stats = require './stats'

app = module.exports = express()

app.configure ->
    if git.user and git.pass
        app.use express.basicAuth (user, pass) ->
            user == git.user and pass == git.pass

    app.set 'views', __dirname + '/views'
    app.set 'quiet', true
    # use coffeekup for html markup
    app.set 'view engine', 'coffee'
    app.engine 'coffee', require('coffeecup').__express
    app.set 'view options', {
        layout: false
    }

    # this must be BEFORE other app.use
    app.use stylus.middleware
        debug: false
        src: __dirname + '/views'
        dest: __dirname + '/public'
        compile: (str)->
            stylus(str).set 'compress', true

    app.use express.logger()
    app.use app.router
    app.use express.static __dirname + '/public'

app.configure 'development', ->
    app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
    app.use express.errorHandler dumpExceptions: true, showStack: true

app.get '/', (req, res) ->
    jobs.getLatest (jobs)->
        res.render 'index',
            project: path.basename process.cwd()
            jobs: jobs,
            moment: moment
app.get '/stats', (req, res) ->
    res.render 'stats',
            project: path.basename process.cwd()

app.get '/jobs', (req, res) ->
    jobs.getAll (jobs)->
        res.json jobs

app.get '/job/:id', (req, res) ->
    jobs.get req.params.id, (job) ->
        res.json job

app.get '/job/:id/:attribute', (req, res) ->
    jobs.get req.params.id, (job) ->
        if job[req.params.attribute]?
            # if req.xhr...
            res.json job[req.params.attribute]
        else
            res.send "The job doesn't have the #{req.params.attribute} attribute"

app.get '/clear', (req, res) ->
    jobs.clear ->
        res.redirect '/jobs'

app.get '/add', (req, res) ->
    jobs.addJob ->
        res.redirect '/jobs'

app.get '/ping', (req, res) ->
    jobs.getLast (job) ->
        if job.failed
            res.send(412)
        else
            res.send(200)

app.post '/', (req, res) ->
    jobs.addJob (job)->
        runner.build()
        if req.xhr
            console.log job
            res.json job
        else
            res.redirect '/'

app.get '/stats/build-time', (req,res) ->
  stats.buildTime (builds) ->
    res.json builds

app.get '/stats/number-of-tests', (req,res) ->
  stats.numberOfTests (n) ->
    res.json n
