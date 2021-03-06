#!/usr/bin/env bash

if [ $# -lt 3 ]
  then
    echo "Arguments needed: <user>@<server> webroot url-without-www"
    echo "e.g. l33th4x0r@login.servershop.com www/ sitename.com"
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $(dirname $DIR)

SERVERROOT=$(ssh $1 "pwd")
WEBROOT=$SERVERROOT/"$2"

# remove repo stuff if installed via git
rm -rf $(dirname $DIR)/.git

# Reset config status
sed -i.bak "s/'live'/'prelaunch'/g" $DIR/../config/b3_config.php && rm $DIR/../config/b3_config.php.bak

# Edit config
$EDITOR $DIR/../config/b3_config.php

# Configure server environment
cat > $DIR/../.env <<- EOM
# SERVER ENVIRONMENT CONFIGURATION

EOM
cat $DIR/../.env.example | sed 's/array/database/g' >> $DIR/../.env

KEY=$(php -r "echo md5(uniqid()).\"\n\";")
sed -i '' -e 's/secret/'$KEY'/g' $DIR/../.env
$EDITOR $DIR/../.env

# Only create dummy content if none exists
if [ $(find $DIR/../public/content/ -maxdepth 0 -type d -empty 2>/dev/null) ]; then

# Create dummy index page
mkdir -p $DIR/../public/content/pages
cat > $DIR/../public/content/pages/index.md <<- EOM
---

title: About
slug: useless
#    [optional]
published: true
#    [optional]
type: index
#    [optional, get theme template based on name]
style: dark | light | default
#    [optional, set css class based on name]
transparent: false | true
#    [optional, set css class based on name]

---

Lorem ipsum.

EOM

# Create dummy post
mkdir -p $DIR/../public/content/blog/`date +%Y/%m/%d`
curl -o $DIR/../public/content/blog/`date +%Y/%m/%d`/Lenna.png https://upload.wikimedia.org/wikipedia/en/2/24/Lenna.png
cat > $DIR/../public/content/blog/`date +%Y/%m/%d`/test.md <<- EOM
---

title: Blog post
language: English
category: Test-Category
tags: one, two, three
slug: URLified-title-here
#    [optional]
modified: 2016-07-30
#    [optional]
lead: intro
#    [optional]
published: true
#    [optional]
type: feature
#    [optional, get theme template based on name]
style: dark | light | default
#    [optional, set css class based on name]
transparent: false | true
#    [optional, set css class based on name]

---

###Test
![alt text](Lenna.png "Logo Title Text 1")

This is my **markdown** content!

EOM

# Create dummy project
mkdir -p $DIR/../public/content/projects/Category
cat > $DIR/../public/content/projects/Category/project.md <<- EOM
---

title: Project One
slug:
#    [optional]
date: 2016-07-30
    [optional]
description: desc
#    [optional]
list-group: Language/Genre
list-title: Built with
list-content: Technology, more technology
published: true
#    [optional]
type: software
#    [optional, get theme template based on name]
style: dark | light | default
#    [optional, set css class based on name]
transparent: false | true
#    [optional, set css class based on name]

---

Lorem ipsum
EOM

# Create dummy flat page
cat > $DIR/../public/content/pages/contact.md <<- EOM
title: Contact
slug: contact
#    [optional]
published: true
#    [optional]
type: page
#    [optional, get theme template based on name]
style: dark | light | default
#    [optional, set css class based on name]
transparent: false | true
#    [optional, set css class based on name]

---

<p class="lead">Description...</p>

Testings
EOM
fi

# Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

# Populate local DB
bash $DIR/populate-db.sh

# Set up key exchange with server
cat ~/.ssh/id_rsa.pub | ssh $1 'cat >> .ssh/authorized_keys'

# Put site URL in .htaccess
sed -i -e "s/example.com/$3/g" $DIR/../public/.htaccess

# Copy B3 installation to server
rsync -alz --stats --progress --exclude=".git" --exclude 'public/themes/default/assets/bower_components' --exclude 'public/themes/default/assets/node_modules' $DIR/../. $1:$WEBROOT/

# Create git repo
git init $DIR/..

# Ignore everything except user content and themes
cat > $DIR/../.gitignore <<- EOM
*
!*/
/storage
/vendor
!/config/b3_config.php
!/public/content/**
/public/content/**/*-optimized.*
/public/content/**/*-thumbnail.*
/public/content/_*
!/public/themes/**
/public/themes/debug
/public/themes/default
!/public/subsites/**
**/.DS_Store
**/node_modules
**/bower_components
!/public/subsites/**/node_modules
!/public/subsites/**/bower_components

EOM

# Add first commit
git add -A && git commit -m "Set up repo"

# Set up git hooks and scripts on server and client
HOOK="#!/bin/sh
git --work-tree=$WEBROOT --git-dir=$SERVERROOT/repo/site.git checkout -f master
cd $WEBROOT && bash $WEBROOT/scripts/populate-db.sh
rm -rf $WEBROOT/storage/framework/cache/ && bash $WEBROOT/scripts/clearCache.sh"
ssh $1 "mkdir repo && cd repo && mkdir site.git && cd site.git && git init --bare && cd hooks && echo '$HOOK' > post-receive && chmod +x post-receive"

git remote add live ssh://$1$SERVERROOT/repo/site.git

# Configure local environment
cat > $DIR/../.env <<- EOM
# LOCAL ENVIRONMENT CONFIGURATION

EOM
cat $DIR/../.env.example >> $DIR/../.env

KEY=$(php -r "echo md5(uniqid()).\"\n\";")
sed -i '' -e 's/secret/'$KEY'/g' $DIR/../.env
$EDITOR $DIR/../.env

git push live master

cd - > /dev/null 2>&1

echo "To publish changes, issue the following command:    git push live master"
