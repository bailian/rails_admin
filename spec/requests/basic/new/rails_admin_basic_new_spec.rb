require 'spec_helper'

describe "RailsAdmin Basic New" do
  include Warden::Test::Helpers

  before(:each) do
    RailsAdmin::AbstractModel.new("Division").destroy_all!
    RailsAdmin::AbstractModel.new("Draft").destroy_all!
    RailsAdmin::AbstractModel.new("Fan").destroy_all!
    RailsAdmin::AbstractModel.new("League").destroy_all!
    RailsAdmin::AbstractModel.new("Player").destroy_all!
    RailsAdmin::AbstractModel.new("Team").destroy_all!
    RailsAdmin::AbstractModel.new("User").destroy_all!

    user = RailsAdmin::AbstractModel.new("User").create(
      :email => "test@test.com",
      :password => "test1234"
    )

    login_as user
  end

  after(:each) do
    Warden.test_reset!
  end
  
  #new

  describe "GET /admin/player/new" do
    before(:each) do
      get rails_admin_new_path(:model_name => "player")
    end

    it "should respond sucessfully" do
      response.should be_successful
    end

    it "should show \"New model\"" do
      response.body.should contain("New player")
    end

    it "should show required fields as \"Required\"" do
      response.body.should contain(/Name\n\s*Required/)
      response.body.should contain(/Number\n\s*Required/)
    end

    it "should show non-required fields as \"Optional\"" do
      response.body.should contain(/Position\n\s*Optional/)
      response.body.should contain(/Born on\n\s*Optional/)
      response.body.should contain(/Notes\n\s*Optional/)
    end
  end

  describe "GET /admin/player/new with has-one association" do
    before(:each) do
      RailsAdmin::AbstractModel.new("Draft").create(:player_id => rand(99999), :team_id => rand(99999), :date => Date.today, :round => rand(50), :pick => rand(30), :overall => rand(1500))
      get rails_admin_new_path(:model_name => "player")

    end

    it "should respond sucessfully" do
      response.should be_successful
    end

    it "should show associated objects" do
      response.body.should contain(/Draft #\d+/)
    end
  end

  describe "GET /admin/player/new with has-many association" do
    before(:each) do
      (1..3).each do |number|
        RailsAdmin::AbstractModel.new("Team").create(:league_id => rand(99999), :division_id => rand(99999), :name => "Team #{number}", :manager => "Manager #{number}", :founded => 1869 + rand(130), :wins => (wins = rand(163)), :losses => 162 - wins, :win_percentage => ("%.3f" % (wins.to_f / 162)).to_f)
      end

      get rails_admin_new_path(:model_name => "player")
    end

    it "should respond sucessfully" do
      response.should be_successful
    end

    it "should show associated objects" do
      response.body.should contain(/Team 1Team 2Team 3/)
    end
  end

  describe "GET /admin/team/:id/fans/new with has-and-belongs-to-many association" do
    before(:each) do
      (1..3).each do |number|
        RailsAdmin::AbstractModel.new("Team").create(:league_id => rand(99999), :division_id => rand(99999), :name => "Team #{number}", :manager => "Manager #{number}", :founded => 1869 + rand(130), :wins => (wins = rand(163)), :losses => 162 - wins, :win_percentage => ("%.3f" % (wins.to_f / 162)).to_f)
      end

      get rails_admin_new_path(:model_name => "fan")
    end

    it "should respond sucessfully" do
      response.should be_successful
    end

    it "should show associated objects" do
      response.body.should contain(/Team 1.*Team 2.*Team 3/)
    end
  end

  describe "GET /admin/player/new with missing label" do
    before(:each) do
      (1..3).each do |number|
        RailsAdmin::AbstractModel.new("Team").create(:league_id => rand(99999), :division_id => rand(99999), :manager => "Manager #{number}", :founded => 1869 + rand(130), :wins => (wins = rand(163)), :losses => 162 - wins, :win_percentage => ("%.3f" % (wins.to_f / 162)).to_f)
      end
      get rails_admin_new_path(:model_name => "player")
    end

    it "should respond sucessfully" do
      response.should be_successful
    end
  end
end