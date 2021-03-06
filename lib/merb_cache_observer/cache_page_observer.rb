class Merb::Cache::Observer
  cattr_accessor :page_observers
  self.page_observers = {}

  def self.add_page_observer(models, controller, action)

    if controller._page_observer? action
      models = controller._page_observers[action][:models] | models
      controller._page_observers[action] = nil
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
    controller._page_observers[action] = { :models => models,
                                           :observer => observer }
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

module Merb::Cache::Observer::ControllerInstanceMethods

  def _page_observers
    self._observer.page_observers[controller_name] ||= {}
  end

  def _page_observer?(action)
    _page_observers.key? action
  end
end
