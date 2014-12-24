var React = require('react');
var Router = require('react-router');
var mui = require('material-ui');
var RaisedButton = mui.RaisedButton;

var AboutPage = React.createClass({

  mixins: [Router.Navigation],

  render: function() {

    return (
      <div className="pure-g">
        <h2>About</h2>
      </div>
    );
  }

});

module.exports = AboutPage;
