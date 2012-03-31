# Start xvfb in preparation for cucumber
sh -e /etc/init.d/xvfb start

# fetch extjs
wget http://extjs.cachefly.net/ext-4.0.2a-gpl.zip
unzip -q -d test/basepack_test_app/public/ -n ext-4.0.2a-gpl.zip
mv test/core_test_app/public/ext-4.0.2a test/core_test_app/public/extjs

# cp db configuration
cp test/core_test_app/config/database.yml.travis  test/core_test_app/config/database.yml

# create mysql database
mysql -e 'create database nct_test;'

bundle install
bundle exec rake db:migrate RAILS_ENV=test
cd ../..
