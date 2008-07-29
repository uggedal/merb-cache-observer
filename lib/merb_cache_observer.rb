if defined?(Merb::Plugins)

  require 'merb_cache_observer/cache_observer'

  Merb::Plugins.config[:merb_cache_observer] = {}
  
  Merb::BootLoader.before_app_loads do
  end
  
  Merb::BootLoader.after_app_loads do
  end
end
