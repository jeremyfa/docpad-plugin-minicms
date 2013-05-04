miniCMS
=======

## Add admin features to Docpad

![screen1](https://github.com/jeremyfa/docpad-plugin-minicms/raw/master/screens/screen1.png)

### An admin panel for Docpad?

_I know there has been [a lot of talk](https://github.com/bevry/docpad/issues/123) about defining a roadmap to build a docpad GUI, but I needed an admin panel with basic CMS features right now, so I just made one. It is far from being perfect but it works._

### Key features

* Configure everything on your docpad.coffee file: **admin path**, **password**, **lists**, **filters**, **forms**…
* List and Manage your content with a very easy user interface
* Create forms to edit your content with built-in components: **datepicker**, **wysiwyg**, **markdown**, **image upload**, **tags with autocomplete**…

## How to use

Run ```npm install docpad-plugin-minicms```

Then, you should definitely take a look at the [docpad.coffee](https://github.com/jeremyfa/docpad-plugin-minicms/blob/master/examples/blog/docpad.coffee) file of the blog example project in order to know how to configure the plugin.

## Demo

To run the demo, download the [zip file including a blog example project](https://github.com/jeremyfa/docpad-plugin-minicms/archive/master.zip).

Go to the ``examples/blog/`` directory and run:

```
npm install
./app run
```

Then you can try the admin panel by going on http://localhost:9778/cms/ (access: admin/password) and see what it becomes on clicking the "Site" item of the navbar.

#### Articles listing in admin panel

![screen2](https://github.com/jeremyfa/docpad-plugin-minicms/raw/master/screens/screen2.png)

#### Editing an article

![screen4](https://github.com/jeremyfa/docpad-plugin-minicms/raw/master/screens/screen4.png)

#### Blog example resulting main page

![screen3](https://github.com/jeremyfa/docpad-plugin-minicms/raw/master/screens/screen3.png)

## Thanks to...

_All these projects that were very helpful:_

* [Docpad](http://docpad.org)
* [Epic Editor](http://epiceditor.com)
* [Twitter Bootstrap](http://twitter.github.io/bootstrap)
* [Wysihtml5 (on Bootstrap)](http://jhollingworth.github.io/bootstrap-wysihtml5)
* [Tag-it!](http://aehlke.github.io/tag-it)
* [Bootstrap Datetime Picker](http://tarruda.github.io/bootstrap-datetimepicker)
* [jQuery File Upload](http://blueimp.github.io/jQuery-File-Upload)
