# encoding: UTF-8

get '/m1' do
  logger.debug "="*80
  #City.find(1).try(:name)
  #City.where(:name => '北京').first.try(:name)
  City.where(:name => '北京').find(1).try(:name)
  #"北京a"
end
