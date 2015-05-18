require 'redis'
require 'marker'

module Wup
  class << self
    attr_accessor :webroot, :redis

    def root
      File.expand_path('../..', __FILE__)
    end
  end

  self.webroot = File.expand_path(ENV['WUP_WEBROOT']||'~/data/public')
  self.redis = Redis.new #support REDIS_URL environment variable 

  module FileTool
    extend self

    def subfiles dir, support_link = false
      files = Dir.glob(File.join(dir, '*'))
      files.reject! do |f| 
        f.end_with?('~') or f =~ /\.sw./ or (!support_link and File.symlink?(f))
      end
      files.sort
    end
  end
end
