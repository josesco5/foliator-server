bundle install

mkdir -p tmp/puma/log

bundle exec puma --config config/puma.rb
