require 'merb_cache_observer/cache_page_observer'

class Merb::Cache::Observer
end

module Merb
  class Controller
    cattr_reader :_observer
    @@_observer = Merb::Cache::Observer.new

    include Merb::Cache::Observer::ControllerInstanceMethods

    class << self
      include Merb::Cache::Observer::ControllerClassMethods
    end
  end
end
