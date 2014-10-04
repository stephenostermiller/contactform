#!/bin/sh

export HTTP_ACCEPT_LANGUAGE=en
export HTTP_HOST=example.com
export HTTP_REFERER="http://someothersite.example.com/foo.html"
export HTTPS=ON
export HTTP_USER_AGENT="TestingAgent/4.3"
export PATH_INFO=""
export QUERY_STRING=""
export REMOTE_ADDR="8.8.8.8"
export REMOTE_HOST="client.example.com"
export REMOTE_USER=""
export REQUEST_METHOD=GET
export SCRIPT_NAME="/contact.pl"
export SERVER_ADMIN="admin@example.com"
export SERVER_NAME="web1.example.com"
export SERVER_PORT=8080

src/contact.pl
