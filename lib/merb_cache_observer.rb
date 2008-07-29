if defined?(Merb::Plugins)
  Merb::Plugins.config[:merb_cache_observer] = {}

  require 'dm-observer'
  require 'merb_cache_observer/cache_observer'
end
