// Generated by CoffeeScript 1.9.3
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(["Nsend"], function(Pi) {
  var LoginInit;
  return LoginInit = (function(superClass) {
    extend(LoginInit, superClass);

    function LoginInit() {
      return LoginInit.__super__.constructor.apply(this, arguments);
    }

    LoginInit.prototype.init = function() {
      return this.wait_ajax_done((function(_this) {
        return function() {
          if (_this.e.attr("processed") === "2") {
            return;
          }
          return _this.rpc("#bullet@check_user_id");
        };
      })(this));
    };

    return LoginInit;

  })(Pi);
});