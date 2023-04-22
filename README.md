# Gryphon Nest

Yet another static website builder based on the script originally used to build my own website. Build for those who like to work with HTML and [Mustache](https://mustache.github.io/), most likely just me.

## Installation

To install run:

```sh
[sudo] gem install gryphon_nest
```

## Usage

### Commands

Gryphon provides the executable script `nest` which supports two commands, build and serve:

* build: Generates your website and stores it in the `_site` folder.

* serve: Rebuilds your website and starts a local server for viewing the built site.

## Project Strucutre

Gryphon Nest requires this folder structure:

```txt
project_directory/
        content/
            index.mustache
        layouts/
            main.mustache
        assets/
            main.css
            favicon.ico
        data/
            index.yaml
```

### Content

This folder stores your html files as mustache template files. All files will be expanded to `_site/fileName/index.html` e.g. contact.mustache -> `_site/contact/index.html`, except for the `index.mustache` file which is saved as `index.html`

### Layouts

An optional folder which stores mustache files that wrap around the content of the files stored in the content folder. If it exists, gryphon will use the  `main.mustache` file unless you specify an override `layout` key in the associated datafile.

All layout files follow this basic format.

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

The `yield` block is replaced with the content of the transformed content file.

### Data

An optional folder which stores yaml files containing the context for mustache when building your webpages. If a content file has an associated yaml file e.g. `content/contact.mustache` and `data/contact.yaml`, gryphon will use the file while rendering the final html file. The context will also be available in the layout file.

### Assets

Folder for storing additonal static files such as stylesheets and images. Copies them as is into the `_site` folder in the same folder structure.
