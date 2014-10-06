(function() {
  define(["angular"], function(angular) {
    return angular.module('baobab.directive.inParticipants', []).directive('inParticipants', function() {
      var format, parse;
      format = function(value) {
        var i, p, str, _i, _ref;
        if (value && Object.prototype.toString.call(value) === '[object Array]') {
          str = '';
          for (i = _i = 0, _ref = value.length - 1; _i <= _ref; i = _i += 1) {
            p = value[i];
            if (p && typeof p === 'object' && p.email) {
              if (str.length) {
                str += ', ';
              }
              str += p.email;
            }
          }
          return str;
        }
      };
      parse = function(value) {
        var out, values, _i, _len;
        if (typeof value === 'string') {
          values = value.split(/\s*,\s*/);
          out = [];
          for (_i = 0, _len = values.length; _i < _len; _i++) {
            value = values[_i];
            out.push({
              name: '',
              email: value[i]
            });
          }
          return out;
        }
      };
      return {
        require: 'ngModel',
        link: function(scope, element, attrs, ngModel) {
          ngModel.$formatters.push(format);
          return ngModel.$parsers.push(parse);
        }
      };
    });
  });

}).call(this);