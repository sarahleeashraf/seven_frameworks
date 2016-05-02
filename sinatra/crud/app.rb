require "sinatra"
require "sinatra/respond_with"
require "data_mapper"
require "dm-serializer"

require_relative "bookmark"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!

def get_all_bookmarks
  Bookmark.all(order: :title)
end

class Hash
  def slice(*whitelist)
    whitelist.inject({}) {|result,key| result.merge(key => self[key])}
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def add_tags(bookmark)
    labels = (params["tagsAsString"] || "").split(", ").map(&:strip)

    existing_labels = []

    bookmark.taggings.each do |tagging|
      if labels.include? tagging.tag.label
        existing_labels.push tagging.tag.label
      else
        tagging.destroy
      end
    end

    (labels - existing_labels).each do |label|
      tag = {label: label}
      existing = Tag.first tag
      if !existing
        existing = Tag.create tag
      end

      Tagging.create tag: existing, bookmark: bookmark
  end
end

get "/" do
  @bookmarks = get_all_bookmarks
  respond_with :bookmark_list, @bookmarks
end

get %r{/bookmarks/|d+} do
  id = params[:id]
  bookmark = Bookmark.get(id)
  content_type :json
  bookmark.to_json with_tagList
end

get "/bookmarks/*" do 

  tags = params[:splat].first.split "/"
  bookmarks = Bookmark.all

  tags.each do |tag|
    bookmarks = bookmarks.all({taggings: {tag: {label: tag}}})
  end

  bookmarks.to_json with_tagList
end

get "/bookmark/new" do
  erb :bookmark_form_new
end

post "/bookmarks" do
  input = params.slice "url", "title"
  bookmark = Bookmark.new input

  if bookmark.save
    add_tags(bookmark)
    # Created
    [201, "/bookmarks/#{bookmark['id']}"]
  else
    400 # Bad request
  end
end

get %r{/bookmarks/|d+} do
  id = params[:id]
  bookmark = Bookmarks.get(id)

  if bookmark
    input = params.slice "url", "title"
    if bookmark.update input
      204
    else
      400 #Bad request
    end
  else
    [404, "bookmark #{id} not found"]
end

get %r{/bookmarks/|d+} do
  id = params[:id]
  bookmark = bookmark.get(id)
  bookmark.destroy
  200 # OK
end