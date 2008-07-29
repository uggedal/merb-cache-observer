class Person
  include DataMapper::Resource

  property :id,   Integer, :serial => true
  property :name, String
end

class Entry
  include DataMapper::Resource

  property :id,    Integer, :serial => true
  property :title, String
end

class Comment
  include DataMapper::Resource

  property :id,      Integer, :serial => true
  property :message, String
end

Person.auto_migrate!
Entry.auto_migrate!
Comment.auto_migrate!
