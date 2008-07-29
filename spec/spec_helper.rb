$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'merb-core'
require 'merb-cache'
require 'dm-core'
require 'dm-observer'

require 'merb_cache_observer'

# DataMapper setup

def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s
 
  lib = "do_#{name}"
 
  begin
    gem lib, '>=0.9.3'
    require lib
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] = DataMapper::Repository.adapters[name]
    true
  rescue Gem::LoadError => e
    warn "Could not load #{lib}: #{e}"
    false
  end
end
 
ENV['ADAPTER'] ||= 'sqlite3'
 
HAS_SQLITE3 = load_driver(:sqlite3, 'sqlite3::memory:')
HAS_MYSQL = load_driver(:mysql, 'mysql://localhost/dm_core_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')

# Cache setup

require File.dirname(__FILE__) / 'models'
require File.dirname(__FILE__) / 'controllers'

def use_cache_store(store, orm = nil)
  Merb::Plugins.config[:merb_cache] = {
    :store => store,
    :cache_directory => File.dirname(__FILE__) / "tmp/cache",
    :cache_html_directory => File.dirname(__FILE__) / "tmp/html",
    :no_tracking => false
  }
  FileUtils.rm_rf(Dir.glob(File.dirname(__FILE__) / "/tmp"))
  case store
  when "dummy"
  when "file"
  when "memory"
  when "memcache"
    require "memcache"
  when "database"
    case orm
    when "datamapper"
      Merb.environment = "test"
      Merb.logger = Merb::Logger.new("log/merb_test.log")
      set_database_adapter("sqlite3")
      require "merb_datamapper"
    when "activerecord"
      Merb.logger = Merb::Logger.new("log/merb_test.log")
      set_database_adapter("sqlite3")
      require "merb_activerecord"
    when "sequel"
      set_database_adapter("sqlite")
      require "merb_sequel"
    else
      raise "Unknown orm: #{orm}"
    end
  else
    raise "Unknown cache store: #{store}"
  end
end
 
store = "file"
case ENV["STORE"] || store
when "file"
  use_cache_store "file"
when "memory"
  use_cache_store "memory"
when "memcache"
  use_cache_store "memcache"
when "datamapper"
  use_cache_store "database", "datamapper"
when "sequel"
  use_cache_store "database", "sequel"
when "activerecord"
  use_cache_store "database", "activerecord"
when "dummy"
  use_cache_store "dummy"
else
  puts "Invalid cache store: #{ENV["store"]}"
  exit
end
 
require "fileutils"
FileUtils.mkdir_p(Merb::Plugins.config[:merb_cache][:cache_html_directory])
FileUtils.mkdir_p(Merb::Plugins.config[:merb_cache][:cache_directory])
 
Merb.start :environment => "test", :adapter => "runner"

Merb::Router.prepare do |r|
  r.default_routes
end

require "merb-core/test"
Spec::Runner.configure do |config|
  config.include Merb::Test::RequestHelper
end

PeopleController = People.new(Merb::Test::RequestHelper::FakeRequest.new)
EntriesController = Entries.new(Merb::Test::RequestHelper::FakeRequest.new)
