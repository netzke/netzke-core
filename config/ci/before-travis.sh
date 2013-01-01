# Start xvfb in preparation for cucumber
sh -e /etc/init.d/xvfb start

# fetch extjs
wget http://cdn.sencha.io/ext-4.1.1a-gpl.zip
unzip -q -d test/core_test_app/public/ -n ext-4.1.1a-gpl.zip
mv test/core_test_app/public/ext-4.1.1a test/core_test_app/public/extjs
