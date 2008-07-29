require File.dirname(__FILE__) + '/../spec_helper'

describe Merb::Cache::Observer, 'for pages' do

  before(:each) do
    PeopleController.expire_all
    EntriesController.expire_all

    @person = Person.new(:name => 'Tom')
    @entry = Entry.new(:title => 'Blog post')
    @comment = Comment.new(:message => 'Nice blog post!')
  end

  it 'should provide an array of all page observers' do
    page_observers = Merb::Cache::Observer.page_observers
    page_observers.should be_instance_of(Array)
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
end
