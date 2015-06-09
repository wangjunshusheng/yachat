// Generated by CoffeeScript 1.9.3
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

define(["Nsend", "Cmon"], function(Pi, Cmon) {
  var Profile;
  return Profile = (function(superClass) {
    extend(Profile, superClass);

    function Profile() {
      return Profile.__super__.constructor.apply(this, arguments);
    }

    Profile.prototype.init = function() {
      this.sub("#bullet@user/profile", (function(_this) {
        return function(ev, arg) {
          var status, userInfo;
          status = arg[0], userInfo = arg[1];
          return _this.draw(userInfo);
        };
      })(this));
      return this.wait_ajax_done((function(_this) {
        return function() {
          return _this.query();
        };
      })(this));
    };

    Profile.prototype.draw = function(arg) {
      var email, userId, userName;
      userId = arg[0], userName = arg[1], email = arg[2];
      $("#username", this.e).val(userName);
      return $("#email", this.e).val(email);
    };

    Profile.prototype.query = function() {
      return this.nsend(["user/get", Cmon.sid()], (function(_this) {
        return function(status, sessionId, userInfo) {
          _this.debug(status, userInfo);
          return _this.draw(userInfo);
        };
      })(this));
    };

    Profile.prototype.update = function() {
      var h, l;
      l = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      h = Cmon.list2hash(l);
      return this.nsend(["user/update", Cmon.sid(), "email", h.email, "username", h.username, "password", h.password], (function(_this) {
        return function(status, a) {
          if (status === "ok") {
            _this.info("Profile was updated.");
            return _this.rpc("#bullet@pub_event", ["user/status/registered", Cmon.sid(), h.username, h.email]);
          } else {
            return _this.error("Profile wasn't updated.");
          }
        };
      })(this));
    };

    return Profile;

  })(Pi);
});
