// Generated by IcedCoffeeScript 1.3.3g
(function() {

  module.exports = function() {
    doctype(5);
    html(function() {
      head(function() {
        meta({
          charset: 'utf-8'
        });
        meta({
          'http-equiv': 'content-type',
          content: 'text/html; charset=utf-8'
        });
        meta({
          name: 'viewport',
          content: 'width=device-width, initial-scale=1.0'
        });
        title(this.title);
        link({
          rel: 'stylesheet',
          href: '/' + this.prefix + '/css/bootstrap.css'
        });
        link({
          rel: 'stylesheet',
          href: '/' + this.prefix + '/css/minicms.css'
        });
        link({
          rel: 'stylesheet',
          href: '/' + this.prefix + '/css/jquery-ui/custom.css'
        });
        link({
          rel: 'stylesheet',
          href: '/' + this.prefix + '/css/tag-it.css'
        });
        link({
          rel: 'stylesheet',
          href: '/' + this.prefix + '/css/datetimepicker.css'
        });
        link({
          rel: 'stylesheet',
          href: '/' + this.prefix + '/css/bootstrap-wysihtml5.css'
        });
        link({
          rel: 'stylesheet',
          href: '/' + this.prefix + '/css/wysiwyg-color.css'
        });
        link({
          rel: 'stylesheet',
          href: '/' + this.prefix + '/css/bootstrap-colorpicker.css'
        });
        script({
          src: '/' + this.prefix + '/js/underscore.js'
        });
        script({
          src: '/' + this.prefix + '/js/jquery.js'
        });
        script({
          src: '/' + this.prefix + '/js/jquery-ui.js'
        });
        script({
          src: '/' + this.prefix + '/js/jquery-file-upload.js'
        });
        script({
          src: '/' + this.prefix + '/js/jquery-file-upload-iframe-transport.js'
        });
        script({
          src: '/' + this.prefix + '/js/bootstrap.js'
        });
        script({
          src: '/' + this.prefix + '/js/tag-it.js'
        });
        script({
          src: '/' + this.prefix + '/js/datetimepicker.js'
        });
        script({
          src: '/' + this.prefix + '/js/wysihtml5.js'
        });
        script({
          src: '/' + this.prefix + '/js/bootstrap-wysihtml5.js'
        });
        script({
          src: '/' + this.prefix + '/js/bootstrap-colorpicker.js'
        });
        return script({
          src: '/' + this.prefix + '/vendor/epiceditor/js/epiceditor.js'
        });
      });
      return body('#minicms', {
        'data-prefix': this.prefix
      }, function() {
        div('#navbar.navbar.navbar-inverse.navbar-fixed-top', function() {
          return div('.navbar-inner', function() {
            return div('.container', function() {
              ul('.nav', function() {
                li('.other-button', function() {
                  return a({
                    href: '/'
                  }, function() {
                    span('.icon-home.icon-white', function() {});
                    text(' ');
                    return span('.text', function() {
                      return 'Site';
                    });
                  });
                });
                return li('.other-button.active', function() {
                  return a({
                    href: '/' + this.prefix
                  }, function() {
                    span('.icon-pencil.icon-white', function() {});
                    text(' ');
                    return span('.text', function() {
                      return 'Admin';
                    });
                  });
                });
              });
              return ul('.nav.pull-right', function() {
                li('#docpad-reload-button', function() {
                  return a({
                    href: '/' + this.prefix
                  }, function() {
                    span('.icon-refresh.icon-white', function() {});
                    text(' ');
                    return span('.text', function() {
                      return 'Reload';
                    });
                  });
                });
                return li('#docpad-logout-button.other-button', function() {
                  return a({
                    href: '/' + this.prefix + '/logout'
                  }, function() {
                    span('.icon-circle-arrow-left.icon-white', function() {});
                    text(' ');
                    return span('.text', function() {
                      return 'Log out';
                    });
                  });
                });
              });
            });
          });
        });
        return div('#content.layout-' + this.layout, function() {
          div('#menu.well.well-small', function() {
            return ul('.nav.nav-list', function() {
              var item, _i, _len, _ref, _ref1, _ref2, _results;
              li('.nav-header', function() {
                return 'Content';
              });
              _ref = this.config.models;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                item = _ref[_i];
                if (item.unique) {
                  if (((_ref1 = this.model) != null ? _ref1.name[0] : void 0) === item.name[0]) {
                    _results.push(li('.active', function() {
                      return a({
                        href: '/' + this.prefix + '/' + this.slugify(item.name[0]) + '/edit?url=' + item.form.url
                      }, function() {
                        return h(item.name[1]);
                      });
                    }));
                  } else {
                    _results.push(li(function() {
                      return a({
                        href: '/' + this.prefix + '/' + this.slugify(item.name[0]) + '/edit?url=' + item.form.url
                      }, function() {
                        return h(item.name[1]);
                      });
                    }));
                  }
                } else if (((_ref2 = this.model) != null ? _ref2.name[0] : void 0) === item.name[0]) {
                  _results.push(li('.active', function() {
                    return a({
                      href: '/' + this.prefix + '/' + this.slugify(item.name[0]) + '/list'
                    }, function() {
                      return h(item.name[1]);
                    });
                  }));
                } else {
                  _results.push(li(function() {
                    return a({
                      href: '/' + this.prefix + '/' + this.slugify(item.name[0]) + '/list'
                    }, function() {
                      return h(item.name[1]);
                    });
                  }));
                }
              }
              return _results;
            });
          });
          return div('#page', function() {
            return p(function() {
              return text(this.content);
            });
          });
        });
      });
    });
    return coffeescript(function() {
      return $(document).ready(function() {
        var prefix;
        prefix = $('#minicms').data('prefix');
        $('#navbar .other-button').click(function(e) {
          if ($('#docpad-reload-button').hasClass('active')) {
            return e.preventDefault();
          }
        });
        return $('#docpad-reload-button').click(function(e) {
          e.preventDefault();
          if ($('#docpad-reload-button').hasClass('active')) return;
          $('#content').empty();
          $('#navbar .other-button').css({
            visibility: 'hidden',
            position: 'relative',
            left: '-9999px',
            top: '-9999px'
          });
          $('#docpad-reload-button').addClass('active');
          $('#docpad-reload-button span.icon-refresh').css({
            backgroundImage: 'url("/' + prefix + '/img/loader-inverted.gif")',
            backgroundPosition: 'center',
            backgroundRepeat: 'no-repeat',
            opacity: 1
          });
          $('#docpad-reload-button span.text').html('&nbsp;Reloading...');
          return $.ajax({
            url: '/' + prefix + '/generate',
            type: 'POST',
            error: function() {
              return document.location.reload();
            },
            success: function() {
              return document.location.reload();
            }
          });
        });
      });
    });
  };

}).call(this);
