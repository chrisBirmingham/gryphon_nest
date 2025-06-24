# Gryphon Nest

Yet another static website builder. Starting as a simple ruby script to build my own website it's now been converted into a gem for others to use. The main audience of this gem is those who like to work with HTML and [Mustache](https://mustache.github.io/), so probably just me :)

## Installation

To install run:

```commandline
[sudo] gem install gryphon_nest
```

Or include in your websites `Gemfile`

```ruby
gem 'gryphon_nest', '~> 4.1'
```

And run

```commandline
bundle install
```

## Usage

Gryphon provides the executable `nest` which currently supports these commands:

* build: Generates your website and stores it in the `_site` folder.

* serve: Builds your website and starts a local server for viewing the built site.

* clean: Deletes the `_site` folder

The build command accepts these options:

* compress: Creates a gzipped version of each file. Intended for use with web servers that support sending gzipped content directly such as nginx via it's [gzip_static module](https://nginx.org/en/docs/http/ngx_http_gzip_static_module.html). This will only build compressed files for files that have been modified, use the force flag to compress everything.

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
    data/
        index.yaml
    layout.mustache
```

### Content

This filder is where you put all the content for your website. Mustache template files are expanded to `_site/basename/index.html` for clean URLs e.g. contact.mustache -> `_site/contact/index.html`, except for the `index.mustache` file which is saved as `index.html`. Non template files are copied as is into the same location in the output directory. If the sas-embedded gem is available, sass and scss files will be processed.

Gryphon will always rebuild template files but will only move asset files if they have been modified. If a file exists in the output folder that doesn't exist in the content folder, it will be deleted.

If a template file contains invalid mustache or the resulting html is invalid, gryphon stops processing and exits with an non-zero exit code.

If a file is added, modified or deleted while nest is watching for file changes, those changes will be applied in real time to the currently running server.

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

Unlike content and data files, if this file is modified while gryphon is  watching for file changes, those changes won't be applied and you'll need to restart the local server to view said changes.

### Data

An optional folder containing yaml files providing context for mustache when it renders a template file. Gryphon will use the data file with the same basename as the context file it's currently processing eg `contact.mustache -> contact.yaml`. The provided context will also be available to the layout file if one is provided.

If a data file is added, modified or deleted while gryphon is watching for file changes, the associated html page will be regenerated should the mustache template exist.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chrisBirmingham/gryphon_nest.
