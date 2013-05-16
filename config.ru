# encoding: UTF-8

USE_MEM_CACHE = true


ENV['RACK_ENV'] ||= "development"

ENV['BUNDLE_GEMFILE'] ||= ::File.expand_path('../Gemfile', __FILE__)
require 'bundler/setup' if ::File.exists?(ENV['BUNDLE_GEMFILE'])
::Bundler.require(:default, ENV['RACK_ENV'])

ENV['APP_ROOT'] ||= ::File.expand_path(::File.dirname(__FILE__))
ENV['LOG_PATH'] ||= ::File.expand_path(::File.join(ENV['APP_ROOT'],'log'))

require 'sinatra'
require 'sinatra/reloader' if development?
#require 'sinatra/contrib/all'

app_config_path  = ::File.expand_path("../config", __FILE__) + '/app_config.yml'
APP_CONFIG = ::YAML.load_file(app_config_path)[ENV["RACK_ENV"]] if File.exists?(app_config_path)


require 'logger'
::Dir.mkdir(ENV['LOG_PATH']) unless ::File.exist?(ENV['LOG_PATH'])
class ::Logger; alias_method :write, :<<; end
log_file = "#{ENV['LOG_PATH']}/#{ENV["RACK_ENV"]}.log"

case ENV["RACK_ENV"]
when "production" then
  $common_logger = ::Logger.new(log_file)
  $common_logger.level = ::Logger::WARN
  #$common_logger.level = ::Logger::DEBUG
when "development" then
  $common_logger = ::Logger.new(log_file)
  $common_logger.level = ::Logger::DEBUG
when "test" then
  $common_logger = ::Logger.new(log_file)
  $common_logger.level = ::Logger::DEBUG
else
  $common_logger = ::Logger.new("/dev/null")
end

helpers do
  def logger
    $common_logger
  end
end


before do
  begin
    s = ""
    s << "\n"
    s << "Processing #{request.path} (for #{request.ip} at #{Time.new.strftime("%Y-%m-%d %H:%M:%S")}) [#{request.request_method}]"
    s << "\nURL: #{request.url}"
    s << "\nParameters: #{params}" if params
    s << "\n"
    logger << s
  end
end

after do
  begin
    logger << "Completed "
  end
end



#中文版本介绍 http://www.sinatrarb.com/intro-zh.html
configure do
  #:absolute_redirects
  #如果被禁用，Sinatra会允许使用相对路径重定向，
  #但是，Sinatra就不再遵守 RFC 2616标准 (HTTP 1.1), 该标准只允许绝对路径重定向。
  #如果你的应用运行在一个未恰当设置的反向代理之后，
  #你需要启用这个选项。注意 url 辅助方法 仍然会生成绝对 URL，除非你传入 false 作为第二参数。
  #默认禁用。
  set :absolute_redirects,false

  #add_charsets
  #设定 content_type 辅助方法会 自动加上字符集信息的多媒体类型。
  #你应该添加而不是覆盖这个选项: settings.add_charsets << "application/foobar"

  #app_file
  #主应用文件，用来检测项目的根路径， views和public文件夹和内联模板。
  set :app_file,__FILE__

  #bind
  #绑定的IP 地址 (默认: 0.0.0.0)。 仅对于内置的服务器有用。
  set :bind,"0.0.0.0"

  #port
  #监听的端口号。只对内置服务器有用。
  set :port,3000

  #default_encoding
  #默认编码 (默认为 "utf-8")。
  set :default_encoding,"utf-8"

  #dump_errors
  #在log中显示错误。
  set :dump_errors,true

  #environment
  #当前环境，默认是 ENV['RACK_ENV']， 或者 "development" 如果不可用。
  set :environment,ENV['RACK_ENV']

  #使用logger级别
  #set :logging,true#Logger::DEBUG
  set :logging,::Logger::DEBUG

  #lock
  #对每一个请求放置一个锁， 只使用进程并发处理请求。
  #如果你的应用不是线程安全则需启动。 默认禁用。
  set :lock,false

  #method_override
  #使用 _method 魔法以允许在旧的浏览器中在 表单中使用 put/delete 方法
  set :method_override,true

  #prefixed_redirects
  #是否添加 request.script_name 到 重定向请求，如果没有设定绝对路径。
  #那样的话 redirect '/foo' 会和 redirect to('/foo')起相同作用。默认禁用。
  set :prefixed_redirects,false

  #public_folder
  #public文件夹的位置。
  set :public_folder,ENV['APP_ROOT'] + "public"

  #reload_templates
  #是否每个请求都重新载入模板。 在development mode和 Ruby 1.8.6 中被企业（用来 消除一个Ruby内存泄漏的bug）。
  set :reload_templates,development?

  #root
  #项目的根目录。
  set :root,ENV['APP_ROOT']

  #raise_errors
  #抛出异常（应用会停下）。
  set :raise_errors,development?

  #run
  #如果启用，Sinatra会开启web服务器。 如果使用rackup或其他方式则不要启用。
  set :run,false


  #running
  #内置的服务器在运行吗？ 不要修改这个设置！
  #set :running

  #server
  #服务器，或用于内置服务器的列表。 默认是 [‘thin’, ‘mongrel’, ‘webrick’], 顺序表明了 优先级。
  #set :server,['thin','mongrel','webrick']

  #sessions
  #开启基于cookie的sesson。
  set :sessions,false

  #show_exceptions
  #在浏览器中显示一个stack trace。
  set :show_exceptions,development?

  #static
  #Sinatra是否处理静态文件。 当服务器能够处理则禁用。 禁用会增强性能。 默认开启。
  set :static,false

  #views
  #views 文件夹。
  set :views,ENV['APP_ROOT'] + "views"
end

configure :production do
  #set :logging,::Logger::WARN
end

configure :development do
  #set :logging,::Logger::DEBUG
end




# initialize json
# require 'oj'
# require 'yajl'
# require 'active_support'
# ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true


# initialize ActiveRecord
require 'active_record'
require "sinatra/activerecord"
::ActiveRecord::Base.establish_connection ::YAML::load(::File.open('config/database.yml'))[ENV["RACK_ENV"]]
::ActiveRecord::Base.logger = $common_logger
::ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
  self.default_timezone = :local
  self.time_zone_aware_attributes = false
  self.logger = $common_logger
end
use ::ActiveRecord::ConnectionAdapters::ConnectionManagement

if USE_MEM_CACHE
  #http://robbinfan.com/blog/33/activerecord-object-cache
  # initialize memcached
  require 'active_support'
  require 'dalli'
  require 'active_support/cache/dalli_store'
  Dalli.logger = $common_logger
  CACHE = ActiveSupport::Cache::DalliStore.new("127.0.0.1:11211")
  require 'second_level_cache'
  SecondLevelCache.configure do |config|
    config.cache_store = CACHE
    config.logger = $common_logger
    config.cache_key_prefix = 'domain'
  end
end

use ::Rack::CommonLogger,$common_logger

# Set autoload directory
%w{models controllers lib helpers}.each do |dir|
  ::Dir.glob(::File.expand_path("../#{dir}", __FILE__) + '/**/*.rb').each do |file|
    require file
  end
end

run ::Sinatra::Application
