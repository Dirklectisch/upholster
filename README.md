# upholster #

An experimental tool chain for developing CouchDB _design/ documents.

## What's working now? ##

- Assembling a design document from separate source files
- Publishing a design document to a CouchDB database

## What's on the horizon? ##

- Compiling design document functions from separate files

# Usage #

## Installation ##

Installation of upholster is very simple, but you will need to take care of installing the following dependencies yourself.

- Ruby MRI 1.9.x (Rake & YAML gems are included)
- Yajl Ruby Gem (for parsing and encoding JSON)
- Rufus-Verbs Gem (for communicating with CouchDB over HTTP)

Copy the source code to a folder of your choice.

    $ git clone git://github.com/Dirklectisch/upholster.git
    $ git checkout v0.1.0

Create a symbolic link to the ./upholster/bin/holst executable somewhere within your load path.

    $ sudo ln -s ~/path/to/repo/upholster/bin/holst /usr/local/bin/holst
    
Note that both have to be absolute paths for the symbolic link to work. That's it, you are ready to go!

## Assembling a _design/ document ##

A CouchDB design document is a JSON file containing application logic. Editing the raw JSON document isn't ideal to say the least, this is where upholster comes in. You can edit separate files in a regular directory structure and automatically assemble them into a JSON design document for publication to CouchDB. Let's start by initializing an example application 'exampp' by using the 'holst' command line tool.

    $ holst init exampp
    $ cd exampp
    
The 'init' command takes a directory name as an argument which will be the root directory to your design document project. As you can see the ./exampp directory contains a subdirectory ./source. That directory is particularly important because it contains the sources that will be assembled into the JSON design document. Let's try that out.

    $ printf "javascript" > ./source/language.txt
    $ holst assemble
    > Assembling source.json from source/_id.txt source/language.txt
  
The 'assemble' command build your design document into the source.json file. If you open that up you will see two nodes within the JSON tree structure, their property names identical to the file name and their values identical to the file content. File extensions are ignored, every file is included as is. Directories within ./source are assembled into their own JSON document and eventually included in the main source.json file. Let's see how that works.

    $ mkdir ./source/shows
    $ echo -e "function(doc, req) {return {body: \"Hello World\"}}" > ./source/shows/hello.js
    $ holst assemble
    > Assembling source/shows.json from source/shows/hello
    > Assembling source.json from source/_id.txt source/language.txt source/shows.json

We have now included a basic "Hello World" show function in our _design/ document. If you have a CouchDB instance running we can PUT a new database and POST the document over HTTP to try it out.

    $ curl -X PUT http://127.0.0.1:5984/exampp
    > {"ok":true}
    $ curl -X POST -d @./source.json --header "Content-Type: application/json" http://127.0.0.1:5984/exampp
    > {"ok":true,"id":"_design/exampp","rev":"1-3851c8aa21d6a3d12ae335766c350421"}
    $ open http://127.0.0.1:5984/exampp/_design/exampp/_show/hello

That's all there is to say about assembling your design document for now. You can now edit your design document functions in your preferred editor on your local disk.

