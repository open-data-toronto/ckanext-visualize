import requests
from routes import url_for

from ckan import plugins as p
from ckan.tests import helpers

from ckanext.visualize.controllers.visualize import VisualizeDataController
from ckanext.visualize.tests.helpers import mock_pylons


class TestVisualizeDataController(helpers.FunctionalTestBase):

    @classmethod
    def setup_class(self):
        super(TestVisualizeDataController, self).setup_class()

        if not p.plugin_loaded('visualize'):
            p.load('visualize')

    @classmethod
    def teardown_class(self):
        super(TestVisualizeDataController, self).teardown_class()

        p.unload('visualize')

        helpers.reset_db()

    def test_visualize_data_endpoint(self):
        app = self._get_test_app()
        controller =\
            'ckanext.visualize.controllers.visualize:VisualizeDataController'
        action = 'visualize_data'
        route = url_for(controller=controller, action=action)
        response = app.get(route)

        assert '<section class="container visualize-wrapper">' in \
            response.body

    def test_visualize_data_raw_action_call(self):
        mock_pylons()
        ctrl = VisualizeDataController()

        assert '<section class="container visualize-wrapper">' in \
            ctrl.visualize_data()