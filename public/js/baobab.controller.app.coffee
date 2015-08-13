define ['angular'], (angular) ->
  angular.module("baobab.controller.app", [])
    .controller('AppCtrl', [
        '$scope',
        '$namespaces',
        '$inbox',
        '$auth',
        '$location',
        '$cookieStore',
        '$sce',
    ($scope, $namespaces, $inbox, $auth, $location, $cookieStore, $sce) ->
      window.AppCtrl = @

      @inboxAuthURL = $sce.trustAsResourceUrl('https://api.nylas.com/oauth/authorize')
      @inboxClientID = $inbox.appId()
      @inboxRedirectURL = window.location.href.split('/#')[0].replace('index.html', '')
      @loginHint = ''

      @clearToken = $auth.clearToken
      @token = () => $auth.token
      @needToken = () => $auth.needToken()

      @namespace = () => $namespaces.current()

      @theme = $cookieStore.get('baobab_theme') || 'light'
      @setTheme = (theme) =>
        @theme = theme
        $cookieStore.put('baobab_theme', theme)


      @toggleTheme = () =>
        @setTheme({light: 'dark', dark: 'light'}[@theme])


      @cssForTab = (path) =>
        if $location.path().indexOf(path) != -1
          'active'
        else
          ''

      @
    ])
