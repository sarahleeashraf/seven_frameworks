require "data_mapper"

class Tag
  include DataMapper::Resource

  property :id, Serial
  property :label, String, required: true

  has n :taggings
  has n :bookmarks, through: :taggins, order: [:title.asc]
end