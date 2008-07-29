merb_cache_observer
===================

A plugin for the Merb framework that provides easy integration of model
observers for DataMapper which will expire caches.
Based on [Cache watch][1] by nutrun.

Works on page caches for now. The cache is expired when the provided
model class is saved or destroyed.

Imagine we have a People controller with an index page shortly listing all
people in the system. The show page lists detailed account information
for any person. We then want to invalidate the page cache for the index page
when the person model is changed.

class People < Merb::Controller
  cache_pages :index, :show
  observe_pages [:index, Person], [:show, Person, Account]
end

There is also a singular counterpart to cache_page:

class Entries < Merb::Controller
  cache_page :index
  observe_page :index, Entry, Comment
end


[1]: http://nutrun.com/weblog/cache-watch/
