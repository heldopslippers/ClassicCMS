require 'haml'
require 'sinatra/base'
require 'sinatra/support'

module Classiccms
  class CMSController < ApplicationController
    include Classiccms::Routing
    register Sinatra::MultiRender

    set :multi_views,   [File.join(Classiccms::ROOT, 'views/cms'), File.join(Classiccms::ROOT, 'public')]
    set :root, Dir.pwd
    set :public_folder, Proc.new { File.join(Classiccms::ROOT, 'public') }

    post '/add' do
      if !params['cms'].nil?
        begin
          record = Kernel.const_get(params['cms']['model']).new

          record.connections << Connection.new(:parent => params['cms']['position'], :section => params['cms']['section'], :files => params['cms']['files'])
          show :add_window, {}, {:record => record}
        rescue TypeError
          ''
        end
      end
    end
    post '/edit' do
      records = Base.where(_id: params['id'])
      if records.count > 0
        record = records.first
        show :add_window, {}, {:record => record}
      end
    end
    post '/destroy' do
      items = Base.where(_id: params[:id])
      items.first.delete if items.count > 0
    end
    post '/sort' do
      section = params[:section]

      params[:order].each_with_index do |id, index|
        items = Base.where(_id: id)
        if items.count > 0
          item = items.first
          item.connections.where(:section => section).update_all(:order_id => index+1)
        end
      end
    end

    post '/create' do
      params.each do |key, value|
        begin
          record = Kernel.const_get(key).new(value)
        rescue Typeerror
          ''
        end
        if !record.save
          content_type :json
          return record.errors.messages.to_json
        end
      end
    end
    post '/update' do
      params.each do |key, value|
        begin
          record = Kernel.const_get(key).find(value['id'])
          record.update_attributes(value)
        rescue TypeError
          ''
        end
        if !record.save
          content_type :json
          return record.errors.messages.to_json
        end
      end
    end

    get '/*.:extention' do
      pass unless ['css', 'js'].include? params[:extention]
      response.headers['Cache-Control'] = 'public, max-age=86400'
      show params[:splat].join
    end
  end
end
