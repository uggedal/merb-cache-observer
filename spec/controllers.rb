class People < Merb::Controller
  cache_pages :index, :show
  observe_pages [:index, Person], [:show, Person, Entry, Comment]

  def index
    'People#index action'
  end

  def show
    'People#show action'
  end
end

class Entries < Merb::Controller
  cache_page :index
  observe_page :index, Entry, Comment

  def index
    'Entries#index action'
  end
end
