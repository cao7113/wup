#!/usr/bin/env rackup
#\ -E deployment

require 'byebug'

$:.unshift File.expand_path('../lib', __FILE__)
require 'web'

run Sinatra::Application
