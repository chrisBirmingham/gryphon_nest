# Gryphon formally Gryphon Nest

Yet another static website builder. Starting as a simple ruby script to build my own website it's now been converted into a gem for others to use. The main audience of this gem is those who like to work with HTML and [Mustache](https://mustache.github.io/), so probably just me :)

## Installation

To install run:

```commandline
[sudo] gem install gryphon
```

Or include in your websites `Gemfile`

```ruby
gem 'gryphon', '~> 1.0'
```

And run

```commandline
bundle install
```

## Usage

Gryphon provides the executable `gryphon` which currently supports these commands:

* build: Generates your website and stores it in the `_site` folder.

* serve: Builds your website and starts a local server for viewing the built site.

* clean: Deletes the `_site` folder

The build command accepts these options:

* compress: Creates compressed versions of text files. This options will only build compressed files for files that have been modified, use the force flag to compress everything.

* force: Force (re)builds everything, skipping the file modification check.

The serve command accepts these options:

* port: Sets the port to listen too while serving content.

* watch: Tells nest to watch for file changes while serving content.

## Project Strucutre

Gryphon requires this folder structure:

```txt
project_directory/
    content/
        index.mustache
        main.css
        favicon.ico
    layout.mustache
```

### Content

This filder is where you put all the content for your website. Mustache template files are expanded to `_site/basename/index.html` for clean URLs e.g. contact.mustache -> `_site/contact/index.html`, except for the `index.mustache` file which is saved as `index.html`. Non template files are copied as is into the same location in the output directory. If the sas-embedded gem is available, any sass or scss files found will be processed via that gem.

When run, gryphon will first check to see if a file exists inside the `_site` folder already, if it doesn't it will process and move the file otherwise it will check the modification times between the two and only process should the content files modification time be earlier than the destination file's modification time. If a file exists in the output folder that doesn't exist in the content folder, it will be deleted.

If a template file contains invalid mustache or the resulting html is invalid, gryphon stops processing and exits with an non-zero exit code.

If a file is added, modified or deleted while nest is watching for file changes, those changes will be applied in real time to the currently running server.

Mustache templates can optionally contain yaml frontmatter like so:

```yaml
---
title: Hello world
---
{{ title }}
```

If provided, the front matter will be passed to Mustache as it's template context and used in the resulting output.

### Layout

If a `layout.mustache` file exists, it will be used as the wrapper around all mustache files processed by gryphon.

An example of this file is: 

```mustache
<!DOCTYPE html>
<html lang="en-GB">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{title}}</title>
    <link rel="stylesheet" href="styles/main.css">
  </head>
  <body>
    {{> yield }}
  </body>
</html>
```

The `{{> yield }}` block is required and will be replaced with the content of the transformed content file.

## Compression

When the `-c` option is provided, gryphon will compress text files using gzip compression. This is intended for use with web servers that support sending compressed content directly such as nginx via it's [gzip_static module](https://nginx.org/en/docs/http/ngx_http_gzip_static_module.html).

If the [brotli](https://github.com/miyucy/brotli) gem is installed, gryphon will also created a brotli compressed version of said file.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chrisBirmingham/gryphon.
