var React = require('react');
var Router = require('react-router');
var RouteHandler = Router.RouteHandler;
var mui = require('material-ui');
var AppBar = mui.AppBar;
var AppCanvas = mui.AppCanvas;
var Menu = mui.Menu;
var IconButton = mui.IconButton;
var AppLeftNav = require('./app-left-nav.jsx');

var Master = React.createClass({

  mixins: [Router.State],

  render: function() {

    return (
      <AppCanvas predefinedLayout={1}>

        <AppBar
          className="mui-dark-theme"
          onMenuIconButtonTouchTap={this._onMenuIconButtonTouchTap}
          title="Testing"
          zDepth={0}>
        </AppBar>

        <AppLeftNav ref="leftNav" />

        <RouteHandler />

      </AppCanvas>
    );
  },

  _onMenuIconButtonTouchTap: function() {
    this.refs.leftNav.toggle();
  }

});

module.exports = Master;
