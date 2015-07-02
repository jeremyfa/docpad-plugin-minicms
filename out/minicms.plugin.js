// Generated by IcedCoffeeScript 1.8.0-e
(function() {
  var YAML, applyContext, cc, deepCopy, exec, express, fs, gm, sessionBridge, shellEscape, slugify, uuid,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  slugify = require('./utils/slugify');

  cc = require('coffeecup');

  uuid = require('node-uuid');

  gm = require('gm');

  fs = require('fs');

  exec = require('child_process').exec;

  shellEscape = require('./utils/shellEscape');

  deepCopy = require('owl-deepcopy').deepCopy;

  YAML = require('yamljs');

  applyContext = require('./utils/applyContext');

  sessionBridge = require('./utils/sessionBridge');

  express = require('express');

  module.exports = function(BasePlugin) {
    var MinicmsPlugin;
    return MinicmsPlugin = (function(_super) {
      __extends(MinicmsPlugin, _super);

      function MinicmsPlugin() {
        return MinicmsPlugin.__super__.constructor.apply(this, arguments);
      }

      MinicmsPlugin.prototype.name = 'minicms';

      MinicmsPlugin.prototype.config = {
        prefix: {
          url: 'cms',
          meta: 'cms'
        },
        validate: require('./utils/validate'),
        sanitize: require('./utils/sanitize'),
        models: []
      };

      MinicmsPlugin.prototype.serverExtend = function(opts) {
        var app, config, cp, cs, docpad;
        app = opts.server;
        docpad = this.docpad;
        config = this.config;
        exec("rm -rf " + (shellEscape(docpad.config.srcPath + '/files/tmp')), function() {});
        app.use('/' + this.config.prefix.url, express["static"](__dirname + '/static'));
        if (this.config.secret == null) {
          throw "Secret is required for cookie sessions (minicms)";
        }
        cp = express.cookieParser();
        cs = express.cookieSession({
          secret: this.config.secret
        });
        app.get('/' + this.config.prefix.url + '/logout', cp, cs, require('./routes/logout').bind(this));
        app.get('/' + this.config.prefix.url + '/login', cp, cs, require('./routes/login').bind(this));
        app.post('/' + this.config.prefix.url + '/login', cp, cs, require('./routes/loginSubmit').bind(this));
        app.get('/' + this.config.prefix.url, cp, cs, require('./routes/root').bind(this));
        app.get('/' + this.config.prefix.url + '/:content/list', cp, cs, require('./routes/list').bind(this));
        app.get('/' + this.config.prefix.url + '/:content/edit', cp, cs, require('./routes/edit').bind(this));
        app.post('/' + this.config.prefix.url + '/:content/edit', cp, cs, require('./routes/edit').bind(this));
        app.post('/' + this.config.prefix.url + '/generate', cp, cs, require('./routes/generate').bind(this));
        return app.post('/' + this.config.prefix.url + '/:content/:field/upload', cp, cs, express.bodyParser({
          keepExtensions: true
        }), require('./routes/upload').bind(this));
      };

      return MinicmsPlugin;

    })(BasePlugin);
  };

}).call(this);
