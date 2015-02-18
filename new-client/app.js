var app = angular.module('app', [ 'ngRoute' ]);

app.config(function($routeProvider) {
  $routeProvider

  .when('/', {
    templateUrl : 'pages/home.html',
    controller  : 'homeController'
  })

});

app.controller('homeController', function($scope) {
  $scope.message = 'Home!';
});
