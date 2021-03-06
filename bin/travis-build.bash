#!/bin/bash
set -e

echo "This is travis-build.bash..."

echo "Installing the packages that CKAN requires..."
sudo apt-get update -qq
sudo apt-get install solr-jetty

echo "Installing CKAN and its Python dependencies..."
git clone https://github.com/ckan/ckan
cd ckan
echo "CKAN branch: ckan-2.8.2"
git checkout ckan-2.8.2
python setup.py develop
pip install -r requirements.txt --allow-all-external
pip install -r dev-requirements.txt --allow-all-external
cd -

echo "Creating the PostgreSQL user and database..."
sudo -u postgres psql -c "CREATE USER ckan_default WITH PASSWORD 'pass';"
sudo -u postgres psql -c 'CREATE DATABASE ckan_test WITH OWNER ckan_default;'

echo "Creating the DataStore user and database..."
sudo -u postgres psql -c "CREATE USER datastore_default WITH PASSWORD 'ckan_default';"
sudo -u postgres psql -c 'CREATE DATABASE datastore_test WITH OWNER datastore_default;'

echo "SOLR config..."
# Solr is multicore for tests on ckan master, but it's easier to run tests on
# Travis single-core. See https://github.com/ckan/ckan/issues/2972
sed -i -e 's/solr_url.*/solr_url = http:\/\/127.0.0.1:8983\/solr/' ckan/test-core.ini

echo "Initializing the database..."
cd ckan
paster db init -c test-core.ini

echo "Setting DataStore permissions..."
paster datastore set-permissions -c test-core.ini | sudo -u postgres psql
cd -

echo "Installing ckanext-visualize and its requirements..."
python setup.py develop
pip install -r requirements.txt
pip install -r dev-requirements.txt

echo "travis-build.bash is done."
