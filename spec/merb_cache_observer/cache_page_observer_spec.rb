require File.dirname(__FILE__) + '/../spec_helper'

describe Merb::Cache::Observer, 'for pages' do

  before(:each) do
    PeopleController.expire_all
    EntriesController.expire_all

    @person = Person.new(:name => 'Tom')
    @entry = Entry.new(:title => 'Blog post')
    @comment = Comment.new(:message => 'Nice blog post!')

    @page_observers = PeopleController._observer.page_observers
  end

  it 'should provide a hash of all page observers' do
    page_observers = Merb::Cache::Observer.page_observers
    page_observers.should be_instance_of(Hash)
  end

  it 'should expire a page cache on save for an observed model' do
    PeopleController.cached_page?('index').should be_false
    c = get('/people/index')
    c.body.strip.should == 'People#index action'
    PeopleController.cached_page?('index').should be_true

    @person.name = 'Changed'
    @person.save
    PeopleController.cached_page?('index').should be_false
  end

  it 'should expire a page cache on destroy for an observed model' do
    PeopleController.cached_page?('show').should be_false
    c = get('/people/show')
    c.body.strip.should == 'People#show action'
    PeopleController.cached_page?('show').should be_true

    @comment.message = 'Changed'
    @comment.save
    PeopleController.cached_page?('show').should be_false
  end

  it 'should not expire a page cache on changes for an un-observed model' do
    PeopleController.cached_page?('index').should be_false
    c = get('/people/index')
    PeopleController.cached_page?('index').should be_true

    @comment.message = 'Changed'
    @comment.save
    PeopleController.cached_page?('index').should be_true
  end

  it 'should persist after expiration and re-caching' do
    PeopleController.cached_page?('show').should be_false
    c = get('/people/show')
    PeopleController.cached_page?('show').should be_true

    @entry.title = 'Changed'
    @entry.save
    PeopleController.cached_page?('show').should be_false

    c = get('/people/show')
    PeopleController.cached_page?('show').should be_true
  end

  it 'should be able to observe many models with the same observer' do
    PeopleController._page_observers.size.should == 2
    @page_observers['entries'].size.should == 1
  end

  it 'should store information on what action are observed' do
    PeopleController._page_observers.keys.should be_include(:index)
    PeopleController._page_observers.keys.should be_include(:show)
  end

  it 'should store information on what models are observed' do
    @page_observers['entries'][:index][:models].should == [Entry, Comment]
  end

  it 'should only allow one observer for each method' do
    PeopleController._page_observers.size.should == 2
    PeopleController._page_observers[:index][:models].should == [Person]
    class People
      observe_page :index, Entry
    end
    PeopleController._page_observers.size.should == 2
    PeopleController._page_observers[:index][:models].should == [Person, Entry]
  end

  it 'should keep the observeable models unique on changes' do
    EntriesController._page_observers[:index][:models].should == [Entry, Comment]
    class Entries
      observe_page :index, Entry
    end
    EntriesController._page_observers[:index][:models].should == [Entry, Comment]
  end

  it 'should destruct updated observer classes' do
    before = Time.now
    100.times do
      class People
        observe_page :index, Entry
      end
    end
    after = Time.now
    after.should <= (before + 1)
  end
end
