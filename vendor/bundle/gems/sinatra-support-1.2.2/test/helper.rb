require 'rubygems'  unless RUBY_VERSION >= '1.9'
require 'test/unit'
require 'contest'
require 'ohm'
require 'haml'
require 'mocha'
require 'rack/test'
require 'nokogiri'
require 'sinatra/base'

$:.unshift File.expand_path('../../lib', __FILE__)
$:.unshift File.dirname(__FILE__)

require 'sinatra/support'

class Test::Unit::TestCase
  def settings
    @app ||= Sinatra::Application.new
  end

  def self.fixture_path(*a)
    fx *a
  end

  def fixture_path(*a)
    fx *a
  end

  def save_and_open_page
    f = Tempfile.new(['', '.html'])
    path = f.path
    f.close!
    f.unlink

    File.open(path, 'w') { |f| f.write last_response.body }

    system "open \"#{path}\""
  end
end

def fx(*a)
  root = File.expand_path('../fixtures', __FILE__)
  File.join root, a
end
