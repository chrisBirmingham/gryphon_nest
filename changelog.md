# Changelog

## Version 4.1

* Added `clean` command
* Added `compress` flag to created compressed versions of the created files

## Version 4

* Optional sass support added via the `sass-embedded` gem.
* `watch` flag added to watch for file changes and apply them while running local server. Provided via the `listen` gem.
* `psych` and `webrick` gems updated to their latest versions.

## Version 3.1

* Html Beautifier now checks the created html and throws an exception if the html is invalid.

## Version 3

* The `{{{ yield }}}` element in the layout file became the `{{> yield }}` tag.
* The layout file was moved from `layouts/main.mustache` too `./layout.mustache`

## Version 2

* The `asset` and `content` folders have been merged into the `content` folder.
* Data files no longer support the `yml` file extension.
* Individual layout files are no longer supported.
