shared_context :db do
  before :each do
    Mongoid::Config.truncate!
  end

  after :all do
    Mongoid::Config.truncate!
  end
end
