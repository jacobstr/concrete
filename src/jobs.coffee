mongo = require 'mongodb'
path = require 'path'
git = require './git'
db = new mongo.Db "concrete_#{path.basename(process.cwd()).replace(/\./, "-")}", new mongo.Server('localhost', mongo.Connection.DEFAULT_PORT, {auto_reconnect: true}), {safe:true}
db.open (error) ->
    if error
      console.log 'There was an error creating a connection with the Mongo database. Please check that MongoDB is properly installed and running.'.red
      process.exit 1
ObjectID = mongo.BSONPure.ObjectID

jobs = module.exports =
    current: null
    addJob: (next)->
        # Make a global setting with a human name for argv._[0].
        db.collection 'jobs', (error, collection) ->
            job =
                addedTime: new Date().getTime()
                log: ''
                running: false
                finished: false
            git.lastCommit (commit) ->
              job.commit = commit
              collection.insert job, ->
                next(job) if next?

    getQueued: (next)->
        getJobs {running: false}, next

    getRunning: (next)->
        getJobs {running: true}, next

    getAll: (next)->
        getJobs null, next

    getLatest: (next)->
        db.collection 'jobs', (error, collection) ->
            collection.find().sort({addedTime: 1}).limit(50).toArray (error, jobs) ->
                next jobs

    getLast: (next)->
        db.collection 'jobs', (error, collection) ->
            collection.find().sort({$natural:-1}).limit(1).toArray (error, jobs) ->
                if jobs.length > 0
                    next jobs[0]
                else
                    next()
            

    get: (id, next) ->
        db.collection 'jobs', (error, collection) ->
            collection.findOne {_id: new ObjectID id}, (error, job) ->
                if job?
                    next job
                else
                    next "No job found with the id '#{id}'"

    clear: (next)->
        db.dropCollection 'jobs', (error) ->
            next() if next?

    getLog: (id, next)->
        db.collection 'jobs', (error, collection) ->
            collection.findOne {_id: new ObjectID id}, (error, job) ->
                if job?
                    next job.log
                else
                    next "No job found with the id '#{id}'"

    updateLog: (id, string, next)->
        db.collection 'jobs', (error, collection) ->
            collection.findOne {_id: new ObjectID id}, (error, job) ->
                console.log "update log for job #{job}, #{string}"
                return false if not job?
                job.log += "#{string} <br />"
                collection.save job, ->
                    next() if next?

    currentComplete: (success, next)->
        db.collection 'jobs', (error, collection) ->
            collection.findOne {_id: new ObjectID jobs.current}, (error, job) ->
                return false if not job?
                job.running = false
                job.finished = true
                job.failed = not success
                job.finishedTime = new Date().getTime()
                jobs.current = null
                collection.save job, ->
                    if job.failed
                      git.addNote job.commit.sha, "✖ CI FAILED at: #{job.commit.time}"
                    else
                      git.addNote job.commit.sha, "✔ CI PASSED at: #{job.commit.time}"

                    next()

    next: (next)->
        db.collection 'jobs', (error, collection) ->
            collection.findOne {running: false, finished: false}, (error, job) ->
                return false if not job?
                job.running = true
                job.startedTime = new Date().getTime()
                jobs.current = job._id.toString()
                collection.save job, ->
                    next()

getJobs = (filter, next)->
    db.collection 'jobs', (error, collection) ->
        if filter?
            collection.find(filter).sort({addedTime: 1}).toArray (error, results) ->
                next results
        else
            collection.find().sort({addedTime: 1}).toArray (error, results) ->
                next results
