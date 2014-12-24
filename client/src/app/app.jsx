/**
 * @jsx React.DOM
 */

(function () {

  var React = require('react'),
    Router = require('react-router'),
    AppRoutes = require('./app-routes.jsx'),
    injectTapEventPlugin = require("react-tap-event-plugin");

  window.React = React;

  injectTapEventPlugin();

  var source = new EventSource('http://localhost:9292/subscribe');
  var fogHornSound = "foghorn";

  createjs.Sound.registerSound("/sounds/foghorn.mp3", fogHornSound);

  source.addEventListener('pagerduty:ping', function(e) {
    console.log('SSE: pagerduty:ping');
    incident = JSON.parse(e.data);
    $('#incidents tbody').prepend('<tr><td>' + incident.timestamp + '</td><td>-</td><td>ping</td><td></td></tr>')
  }, false);

  source.addEventListener('pagerduty:incident', function(e) {
    createjs.Sound.play(fogHornSound);
    console.log('SSE: pagerduty:incident=[' + e.data) + ']';
    incident = JSON.parse(e.data);
    $('#incidents tbody').prepend('<tr><td>' + incident.timestamp + '</td><td>' + incident.data.id + '</td><td>' + incident.data.trigger_summary_data.subject + '</td><td><a href="' + incident.data.html_url + '" target="_blank">' + incident.data.html_url + '</a></td></tr>')
  }, false);

  source.addEventListener('open', function(e) {
    // Connection was opened.
    console.log('SSE: Open')
  }, false);

  source.addEventListener('error', function(e) {
    if (e.readyState == EventSource.CLOSED) {
      // Connection was closed.
      console.log('SSE: Closed')
    }
  }, false);

  Router
    .create({
      routes: AppRoutes,
      scrollBehavior: Router.ScrollToTopBehavior
    })
    .run(function (Handler) {
      React.render(<Handler/>, document.getElementById("#content"));
    });

})();
