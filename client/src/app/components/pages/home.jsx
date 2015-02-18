var React = require('react');
var Router = require('react-router');
var mui = require('material-ui');
var RaisedButton = mui.RaisedButton;

var HomePage = React.createClass({

  mixins: [Router.Navigation],

  render: function() {

    return (
      <div className="content">
        <h2>Home</h2>

        <table id="incidents" className="pure-table pure-table-striped">
          <thead>
            <tr>
              <th>Date</th>
              <th>ID</th>
              <th>Subject</th>
              <th>URL</th>
              <th>Actions</th>
            </tr>
          </thead>

          <tbody>
          </tbody>
        </table>

      </div>
    );
  }

});

module.exports = HomePage;
