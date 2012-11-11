web: bundle exec rails server thin -p $PORT -e $RACK_ENV
worker: bundle exec rake resque:work
search: elasticsearch -f -D es.config=/usr/local/Cellar/elasticsearch/0.19.10/config/elasticsearch.yml
