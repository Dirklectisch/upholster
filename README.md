# upholster #

An experimental tool chain for developing CouchDB _design/ documents.

## What's working now? ##

- Assembling a _design/ document from separate source files

## What's on the horizon? ##

- Integrated deployment mechanism for _design/ doc's
- Integrated templating workflow for show and list functions

# Usage #

## Installation ##

Installation of upholster is very simple, but you will need to take care of installing the following dependencies yourself.

- Ruby MRI 1.9.x (Rake & YAML gems are included)
- Yajl Ruby (for parsing and encoding JSON)

Copy the source code to a folder of your choice.

    $ git clone git://github.com/Dirklectisch/upholster.git

Create a symbolic link to the ./upholster/bin/holst executable somewhere within your load path.

    $ sudo ln -s /usr/local/bin/holst ./upholster/bin/holst
    
That's it, you are ready to go!    

## Assembling a _design/ document ##

A CouchDB _design/ document is a JSON file containing application logic. Editing the raw JSON document isn't ideal to say the least, this is where upholster comes in. You can edit separate files in a regular directory structure and automatically assemble them into a JSON _design/ document for publication to CouchDB. Let's start by initializing an example application 'exampp' by using the 'holst' command line tool.

    $ holst init exampp
    $ cd exampp
    
The 'init' command takes a directory name as an argument which will be the root directory to your _design/ document project. As you can see the ./exampp directory contains a subdirectory ./source. That directory is particularly important because it contains the sources that will be serialized to the JSON _design/ document. Let's try that out.

    $ echo javascript > ./source/language.txt
    $ holst assemble
    > Assembling source.json from source/_id.txt source/language.txt
  
The 'assemble' command serialized your _design/ document into the source.json file. If you open that up you will see two nodes within the JSON tree structure, their keys identical to the file name and their values identical to the file content. File extensions are ignored, every file is included as is. Directories within ./source are serialized into their own JSON document and eventually included in the main source.json file. Let's see how that works.

    $ mkdir ./source/shows
    $ echo -e "function(doc, req) {return {body: \"Hello World\"}}" > ./source/shows/hello.js
    $ holst assemble
    > Assembling source/shows.json from source/shows/hello
    > Assembling source.json from source/_id.txt source/language.txt source/shows.json

We have now included a basic "Hello World" show function in our _design/ document. If you have a CouchDB instance running we can POST the document over HTTP to try it out.

    $ curl -X PUT http://127.0.0.1:5984/exampp
    > {"ok":true}
    $ curl -X POST -d @./source.json --header "Content-Type: application/json" http://127.0.0.1:5984/exampp
    > {"ok":true,"id":"_design/exampp","rev":"1-3851c8aa21d6a3d12ae335766c350421"}
    $ open http://127.0.0.1:5984/exampp/_design/exampp/_show/hello

That's all there is to say about serializing your _design/ document for now. The next release (v 0.2.0) will include automatic publishing 