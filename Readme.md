# Node.js Whack-a-mole

This is a tech demonstration of the ability of Node.js to handle many asynchronous events.

The project was built to run on Heroku and expects the RedisToGo and Pusher addons to be installed and present in the ENV. You also need access to Pusher's client events beta.

    heroku create appname --stack cedar
    heroku addons:add redistogo
    heroku addons:add pusher
    git push heroku master

