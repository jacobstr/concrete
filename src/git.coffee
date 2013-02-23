# git executor
exec = require('child_process').exec
# cli colors
colors = require 'colors'

# callback to be used once git it good to go
readyCallback = null

# export so we can... `require '../git'`
git = module.exports =
    runner: ''
    branch: ''
    user: ''
    pass: ''
    config:
        runner: 'concrete.runner'
        branch: 'concrete.branch'
        user: 'concrete.user'
        pass: 'concrete.pass'
        webhook: 'concrete.webhook'

    # init at target directory
    init: (target, callback) ->
        # save callback for after git is ready to go
        readyCallback = callback

        # we're using node's path to run directory level operations
        path = require 'path'
        fs = require 'fs'

        # get the full path to target and change the process to that directory
        if target.toString().charAt(0) isnt '/'
            target = process.cwd()+'/'+target
        process.chdir target

        # set up git paths for concrete's post-build executions
        git.target = path.normalize target+'/.git/'
        git.failure = path.normalize target+'/.git/hooks/build-failed'
        git.success = path.normalize target+'/.git/hooks/build-worked'

        # make sure the path exists and is a valid repo
        fs.exists git.target, (exists)->
            if exists is false
                console.log "'#{target}' is not a valid Git repo".red
                process.exit 1
            getUser()
            getPass()
            getWebhook()
            getBranch()
            getRunner()

    # pull from the git repo
    pull: (next)->
        # get the job list so we can queue jobs
        jobs = require './jobs'
        out = "Pulling '#{git.branch}' branch"
        jobs.updateLog jobs.current, out, ->
            console.log out.grey
            exec 'git fetch && git reset --hard origin/' + git.branch, (error, stdout, stderr)=>
                if error?
                    out = "#{error}"
                    jobs.updateLog jobs.current, out
                    console.log out.red
                else
                    out = "Updated '#{git.branch}' branch"
                    jobs.updateLog jobs.current, out, ->
                        console.log out.grey
                        next()
    
    lastCommit: (callback) ->
      exec "git fetch && git rev-list --pretty=format:'%h::::%s::::%ad' -n1 origin/" + git.branch, (err, stdo, stderr) =>
        commit = stdo.split(/(\n|\r)+/)
        p = commit[2].split('::::')
        commit =
          sha: p[0]
          message: p[1]
          time: new Date(Date.parse(p[2]))
        callback(commit)

    addNote: (sha, message) ->
      exec "git notes --ref=ci add -f -m \"#{message}\" #{sha}", (err,stdo,stderr) =>
        #swallow

readStdout = (stdout) ->
  stdout.toString().replace /[\s\r\n]+$/, ''

getUser = ->
    exec 'git config --get ' + git.config.user, (error, stdout, stderr)=>
        if error?
            git.user = ''
        else
            git.user = readStdout stdout

getPass = ->
    exec 'git config --get ' + git.config.pass, (error, stdout, stderr)=>
        if error?
            git.pass = ''
        else
            git.pass = readStdout stdout

getWebhook = ->
    exec 'git config --get ' + git.config.webhook, (error, stdout, stderr)=>
        if error?
            git.webhook = '/webhook'
        else
            git.webhook = readStdout stdout

# get the current working branch
# fallback to master if git.config.branch isn't set
getBranch = ->
    exec 'git config --get ' + git.config.branch, (error, stdout, stderr)=>
        if error?
            git.branch = 'master'
            gitContinue()
        else
            git.branch = readStdout stdout
            git.branch = 'master' if git.branch is ''
            gitContinue()

# get the concrete runner file
getRunner = ->
    exec 'git config --get ' + git.config.runner, (error, stdout, stderr)=>
        if error?
            console.log "Git.getRunner: #{error}".red
            process.exit 1
        else
            git.runner = readStdout stdout
            git.runner = 'none' if git.runner is ''
            gitContinue()

# notify the user of any issue prior to continuing the concrete operation
gitContinue = ->
    if git.branch is 'none'
        git.branch = 'master'
    else if git.branch is ''
        return false

    if git.runner is 'none'
        console.log 'Git.gitContinue: You must specify a Git runner'.red
        process.exit 1
    else if git.runner is ''
        return false
    readyCallback()
