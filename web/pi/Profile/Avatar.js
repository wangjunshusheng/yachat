// Generated by CoffeeScript 1.9.3
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(["Nsend", "Cmon"], function(Pi, Cmon) {
  var ConvText;
  return ConvText = (function(superClass) {
    extend(ConvText, superClass);

    function ConvText() {
      return ConvText.__super__.constructor.apply(this, arguments);
    }

    ConvText.prototype.draw = function(avatarList) {
      var id, im, ref, type;
      this.clear();
      ref = avatarList[0], id = ref[0], type = ref[1];
      im = $("<img>").attr("src", "/store/avatar/" + id).addClass("img-responsive");
      return this.e.append(im);
    };

    ConvText.prototype.query = function() {
      return this.nsend(["user/avatar", Cmon.sid()], (function(_this) {
        return function(status, avatarList) {
          return _this.draw(avatarList);
        };
      })(this));
    };

    ConvText.prototype.init = function() {
      return this.wait_ajax_done((function(_this) {
        return function() {
          return _this.query();
        };
      })(this));
    };

    return ConvText;

  })(Pi);
});