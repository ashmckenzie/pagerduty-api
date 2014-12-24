var React = require('react');
var Router = require('react-router');
var Route = Router.Route;
var Redirect = Router.Redirect;
var DefaultRoute = Router.DefaultRoute;

var Master = require('./components/master.jsx');
var Home = require('./components/pages/home.jsx');
var About = require('./components/pages/about.jsx');

var AppRoutes = (
  <Route name="root" path="/" handler={Master}>
    <Route name="home" handler={Home} />
    <Route name="about" handler={About} />

    <DefaultRoute handler={Home}/>
  </Route>
);

module.exports = AppRoutes;
