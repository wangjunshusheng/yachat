// Generated by CoffeeScript 1.9.3
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(["pi/Pi", "pi/m/Source", "Cmon"], function(aPi, mSource, Cmon) {
  var ConvList;
  return ConvList = (function(superClass) {
    extend(ConvList, superClass);

    function ConvList() {
      return ConvList.__super__.constructor.apply(this, arguments);
    }

    ConvList.prototype.attr = function() {
      return ConvList.__super__.attr.apply(this, arguments).concat(["view"]);
    };

    ConvList.prototype.draw = function() {
      var convId, i, len, tmpl;
      tmpl = this.rt.source(this.a.view);
      this.empty();
      for (i = 0, len = List.length; i < len; i++) {
        convId = List[i];
        this.e.append(tmpl({
          id: convId
        }));
      }
      return this.rt.pi(this.e);
    };

    ConvList.prototype.init = function() {
      this.sub("#bullet@conv/status/join", (function(_this) {
        return function(ev, args) {
          return _this.rpc("#bullet@query_convs");
        };
      })(this));
      this.sub("#bullet@conv/status/part", (function(_this) {
        return function(ev, args) {
          return _this.rpc("#bullet@query_convs");
        };
      })(this));
      return this.wait_ajax_done((function(_this) {
        return function() {
          return _this.rpc("#bullet@query_convs");
        };
      })(this));
    };

    return ConvList;

  })(aPi);
});
