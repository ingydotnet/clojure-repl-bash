clojure-repl-bash
=================

Simple Bash functions to help with Clojure REPL Driven Development


## Synopsis

In a Bash shell:

```
$ git clone https://github.com/ingydotnet/clojure-repl-bash
Cloning into 'clojure-repl-bash'...
$ source clojure-repl-bash/clojure-repl.bash
$ repl-start
REPL server started on port 34403; pid 1248302
$ repl-status
REPL server running on port 34403; pid 1248302
$ repl-connect-lein
Connecting to nREPL at 127.0.0.1:34403
REPL-y 0.5.1, nREPL 1.0.0
Clojure 1.11.1
OpenJDK 64-Bit Server VM 17.0.8.1+1-Ubuntu-0ubuntu122.04
    Docs: (doc function-name-here)
          (find-doc "part-of-name-here")
  Source: (source function-name-here)
 Javadoc: (javadoc java-object-or-class-here)
    Exit: Control+D or (exit) or (quit)
 Results: Stored in vars *1, *2, *3, an exception in *e

user=> exit
Bye for now!
$ repl-stop
i+ kill -9 1248302 1248313
+ rm -f ./.nrepl-port ./.nrepl-pid
REPL server stopped
$
```


## Overview

This project provides tools for helping manage the things I need for using long
running Clojure REPL servers to develop my Clojure projects.


## Installation

Clone this repository:
```
$ git clone https://github.com/clojure-repl-bash /path/to/clojure-repl-bash
```

Add this line to your Bash startup file:
```
source /path/to/clojure-repl-bash/clojure-repl.bash
```

This will add serveral functions to your shell.
They all begin with `repl-` so you can use tab completion to find them.


## Prerequisites

* Git - For getting this repository
* Bash - This project has only been tested on Bash.
  It may work with Zsh.
* Clojure
* Leiningen - Currently `lein` is used to start nREPL servers.


## The REPL Functions

REPL servers are limited to one per directory.
When a REPL server has been started for a directory, 2 files will be created in
that directory:

* `.nrepl-pid` - The process ID (PID) for the server process.
* `.nrepl-port` - The port number that the server is listening on.
  This is a standard file name that many REPL clients look for.

The current `repl-*` commands are:

* `repl-start`
  Start a REPL server for the current directory.
  If a server is already running then call `repl-status`.

* `repl-status`
  Show information for the REPL server running in the current directory.
  This includes the server PID and port number.

* `repl-stop`
  Stop the REPL server running in the current directory.

* `repl-connect-lein`
  Start an 'lein repl' session connected to the current directory's REPL
  server.


## Inspiration

The "correct" way to work on Clojure projects is to start an nREPL server for
the project, and connect various clients and tools to this server as needed.
The server process should remain running for as long as possible.

From my PoV this is neither obvious nor easy for newcomers to Clojure.
There's a lot to learn.
Sean Corfield has an excellent talk called [REPL Driven Development](
https://www.youtube.com/watch?v=gIoadGfm5T8) that is full of useful information
but also presumes a certain level of familiarity with working this way.

This project is driven by my desire to learn this process well, and to encode
my findings as reusable tools that may be helpful to others.
