require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' # if development?
require 'sinatra/activerecord'

set :database, 'sqlite3:leprosorium.db'

class Post < ActiveRecord::Base
  has_many :comments
  validates :content, presence: true
  validates :author, presence: true
end

class Comment < ActiveRecord::Base
  belongs_to :post
  validates :body, presence: true
end

get '/' do
  @posts = Post.order(created_at: :desc)

  erb :main
end

get '/new' do
  erb :new
end

post '/new' do
  @post = Post.new(params)

  if @post.save
    redirect to '/'
  else
    @error = @post.errors.full_messages.first
    erb :new
  end
end

get '/details/:post_id' do
  @post = Post.find(params[:post_id])
  @comments = @post.comments

  erb :details
end

post '/details/:post_id' do
  @post = Post.find(params[:post_id])
  comment = Comment.new(params)

  if comment.save
    redirect to("/details/#{params[:post_id]}")
  else
    @error = comment.errors.full_messages.first
    erb :details
  end
end
