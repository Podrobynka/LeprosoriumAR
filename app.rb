require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' # if development?
require 'sinatra/activerecord'

set :database, 'sqlite3:leprosorium.db'

class Post < ActiveRecord::Base
  # validates :content, presence: true,
  # validates :author, presence: true
end

class Comment < ActiveRecord::Base
  # validates :comment, presence: true
end

get '/' do
  @posts = @db.execute 'select * from posts order by id desc'
  erb :main
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]
  author = params[:author]

  hh = {
    content: 'Type text',
    author: 'Enter your name'
  }

  hh.each do |key, _value|
    if params[key] == ''
      @error = hh[key]
      return erb :new
    end
  end

  # if content.length <= 0
  #   @error = 'Type text'
  #   return erb :new
  # end

  @db.execute %(
    insert into
    posts (created_date, content, author)
    values (datetime(), ?, ?)
    ), content, author

  redirect to '/'
end

get '/details/:post_id' do
  @post_id = params[:post_id]

  getting_post
  getting_comments

  erb :details
end

post '/details/:post_id' do
  @post_id = params[:post_id]
  comment = params[:comment]

  getting_post
  getting_comments

  if comment.length.zero?
    @error = 'Type comment'
    return erb :details
  end

  @db.execute %(
    insert into
    comments (created_date, comment, post_id)
    values (datetime(), ?, ?)
    ), comment, @post_id

  redirect to('/details/' + @post_id)
end
