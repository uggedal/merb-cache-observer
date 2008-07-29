require 'rubygems'
require 'merb-core'
require 'merb-cache'

class Merb::Cache::Observer
  cattr_accessor :page_observers
  self.page_observers = []

  def self.add_page_observer(model, controller, action)
    observer = Class.new do
      include DataMapper::Observer

      observe model

      after :save do
        controller.expire_page(:action => action)
      end

      after :destroy do
        controller.expire_page(:action => action)
      end
    end
    self.page_observers << observer
  end
end

module Merb::Cache::Observer::ControllerClassMethods

  def observe_page(action, *models)
    observe_pages([action, *models])
  end

  def observe_pages(*actions_and_models)
    actions_and_models.each do |action_and_model|
      action = action_and_model.shift
      action_and_model.each do |model|
        observer = Merb::Cache::Observer.add_page_observer(model,
                                                           self.new({}),
                                                           action)
      end
    end
    true
  end
end