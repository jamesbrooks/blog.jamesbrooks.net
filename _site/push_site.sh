#!/bin/bash

rsync -avz --delete ~/Sandbox/blog.jamesbrooks.net/_site/ blog:~/blog.jamesbrooks.net/_site
