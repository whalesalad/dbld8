web: bundle exec rails server thin -p $PORT -e $RACK_ENV
worker: env QUEUE=* bundle exec rake resque:work
