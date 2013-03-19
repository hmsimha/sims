SIMS-  Student Intervention Monitoring System
====
[![Build Status](https://travis-ci.org/vegantech/sims.png?branch=master)](https://travis-ci.org/vegantech/sims)

Track Student Interventions.   


Some of the icons come from the [Silk icon set](http://www.famfamfam.com/lab/icons/silk/).



see deployment for information on how to deploy.    This will be centrally hosted, but you're welcome to set up your own instance and help contribute code.


Note: There are some required gems for testing.  To see them set the `RAILS_ENV` to test:
	rake  gems RAILS_ENV=test


Be sure to set the domain name of the SIMS application in the `config/initializers/host_info.rb` file to send the proper links in emails generated by the application.



Basics for installing SIMS locally (without the tests, which don't work on Windows yet)
Adjust the paths to match your platform `(/ to \)`


	git clone git://github.com/vegantech/sims.git
	cd sims
	bundle



copy the config/database.yml.sqlite3 to config/database.yml
	rake db:migrate
	rake db:fixtures:load
	bundle exec rails s

Then point your browser to http://localhost:3000   to see SIMS.




Production Deployment (without moonshine)
Once you have it setup for development and have Apache setup


sudo gem install passenger
sudo passenger-install-apache2-module

Modify the apache config files following the onscreen directions.    


From your development directory:
Adjust your mail and server settings in the config/deploy/other.rb
sudo gem install capistrano capistrano-ext
cap other deploy:cold
(You might need to setup the database.yml on the server.   If the deploy cold fails, run:
	RAILS_ENV=production bundle exec rake db:migrate db:fixtures:load
	bundle execscript/runner -e production CreateTrainingDistrict.generate_one


cap other deploy:restart



## Making changes to the server ##

To add new packages or make configuration changes on the server, please
edit the following files. They contain examples for common configurations.
If you have any questions about how to make a particular change, the Rails
Machine staff is always ready to help.

- config/moonshine.yml

  Use this file to manage configuration related to deploying and
  running the app: domain name, git repos, package dependencies for
  gems, and more.

- `app/manifests/application_manifest.rb`

  Use this to manage the configuration of everything else on the
  server: define the server 'stack', cron jobs, mail aliases,
  configuration files

## Deploying ##

We're using the multi-stage deployment functionality of the excellent
`capistrano-ext` gem to allow you to separately deploy to your staging
and production server. If you don't already have this gem installed,
please do so by running `sudo gem install capistrano-ext`.

Use `cap staging deploy` to deploy to staging and `cap production
deploy` to update production code.

On every deployment, Moonshine will make sure that all gems, packages, 
and configurations are as specified in `moonshine.yml` and in the
manifest.