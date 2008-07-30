class Merb::Cache::Observer
  cattr_accessor :page_observers
  self.page_observers = {}

  def self.add_page_observer(models, controller, action)
    self.page_observers[controller.controller_name] ||= {}

    if self.page_observers[controller.controller_name].key? action
      pre = self.page_observers[controller.controller_name][action][:models]
      models = pre + models
    end

    observer = Class.new do
      include DataMapper::Observer

      observe *models

      after :save do
        controller.expire_page(:action => action)
      end

      after :destroy do
        controller.expire_page(:action => action)
      end
    end
    meta = { :models => models, :observer => observer }
    self.page_observers[controller.controller_name][action] = meta
  end
end

module Merb::Cache::Observer::ControllerClassMethods

  def observe_page(action, *models)
    observe_pages([action, *models])
  end

  def observe_pages(*actions_and_models)
    actions_and_models.each do |action_and_model|
      action, models = action_and_model.shift, action_and_model

      Merb::Cache::Observer.add_page_observer(models, self.new({}), action)
    end
    true
  end
end
