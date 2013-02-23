# Concrete
Concrete is a minimalistic Continuous Integration server.

![concrete](https://github.com/edy-b/concrete/raw/master/src/screenshot_builds.png)
![concrete](https://github.com/edy-b/concrete/raw/master/src/screenshot_stats.png)

## Quickstart
    git clone https://github.com/edy-b/concrete.git /path/to/concrete
    cd /path/to/concrete
    npm install
    cd yourrepository
    git config --add concrete.runner "shell command"
    /path/to/concrete/bin/concrete .
    open http://localhost:4567

## Usage
    Usage: concrete [-hpv] path_to_git_repo

    Options:
      -h, --host     The hostname or ip of the host to bind to  [default: "0.0.0.0"]
      -p, --port     The port to listen on                      [default: 4567]
      --help         Show this message
      -v, --version  Show version

## Setting the test runner
    git config --add concrete.runner "coffee test/unit.coffee"

## Setting the branch
    git config --add concrete.branch deploy

## Configuring GitHub Webhook
You can have builds trigger automatically whenever a commit is pushed to GitHub
via Webhooks. See your :repo:/settings/hooks and add the WebHook URL `/webhook`.

You may configure the url via:
    git config --add concrete.webhook '/webhook'

## Adding HTTP Basic authentication
    git config --add concrete.user username
    git config --add concrete.pass password

## Post build
After building Concrete will run `.git/hooks/build-failed` or `.git/hooks/build-worked` depending on test outcome. Like all git hooks, they're just shell scripts so put whatever you want in there.


Concrete is **heavily** inspired by [CI Joe](https://github.com/defunkt/cijoe)
