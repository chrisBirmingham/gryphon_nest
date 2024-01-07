# Gryphon Nest

Yet another static website builder. Starting as a simple ruby script to build my own website it's now been converted into a gem for others to use. The main audience of this gem is those who like to work with HTML and [Mustache](https://mustache.github.io/), so probably just me :)

## Installation

To install run:

```commandline
[sudo] gem install gryphon_nest
```

Or include in your websites `Gemfile`

```ruby
gem 'gryphon_nest', '~> 2.0'
```

And run

```commandline
bundle install
```

## Usage

Gryphon provides the executable `nest` which currently supports two commands:

* build: Generates your website and stores it in the `_site` folder.

* serve: Builds your website and starts a local server for viewing the built site.

## Project Strucutre

Gryphon requires this folder structure:

```txt
project_directory/
        content/
            index.mustache
            main.css
            favicon.ico
        layouts/
            main.mustache
        data/
            index.yaml
```

### Content

Where you put all the content for your website. Mustache template files are expanded to `_site/basename/index.html` for clean URLs e.g. contact.mustache -> `_site/contact/index.html`, except for the `index.mustache` file which is saved as `index.html`. Other files are copied as is and in the same folder structure to the output folder.

Gryphon will always rebuild template files but will only move asset files if they have been modified. If a file exists in the output folder that doesn't exist in the content folder. It will be deleted.

### Layouts

If a `main.mustache` file exists in this folder, it will be used as the wrapper around all mustache files inside your content folder.

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
    {{{yield}}}
  </body>
</html>
```

The `{{{yield}}}` block is required and will be replaced with the content of the transformed content file.

### Data

An optional folder containing yaml files providing context for mustache when it renders a template file. Gryphon will use the data file with the same basename as the context file it's currently processing eg `contact.mustache -> contact.yaml`. The provided context will also be available in the layout file if provided.

## Migrating from Version 1

* The `asset` and `content` folders have been merged into just the `content` folder.
* Datafiles no longer support the `yml` file extension
* Individual layout files are no longer supported.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chrisBirmingham/gryphon_nest.
