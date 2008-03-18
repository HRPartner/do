require 'rubygems'
require 'data_objects'
require 'do_postgres'

describe "DataObjects::Postgres::Connection" do
  it "should connect to the db" do
    connection = DataObjects::Connection.new("postgres://postgres@localhost:5432/do_test")
  end
end

describe "DataObjects::Postgres::Command" do
  before :all do
    @connection = DataObjects::Connection.new("postgres://localhost/do_test")
  end
  
  it "should create a command" do
    @connection.create_command("CREATE TABLE users").should be_a_kind_of(DataObjects::Postgres::Command)
  end
  
  it "should set types" do
    command = @connection.create_command("SELECT id, name FROM users")
    command.set_types [Integer, String]
    command.instance_variable_get("@field_types").should == [Integer, String]
  end
  
  it "should execute a non query" do
    command = @connection.create_command("INSERT INTO users (name) VALUES ('Test')")
    result = command.execute_non_query
    result.should be_a_kind_of(DataObjects::Postgres::Result)
  end
end

describe "DataObjects::Postgres::Result" do
  before :all do
    @connection = DataObjects::Connection.new("postgres://localhost/do_test")
  end

  it "should raise errors on bad queries" do
    command = @connection.create_command("INSER INTO users (name) VALUES ('Test')")
    lambda { command.execute_non_query }.should raise_error
    command = @connection.create_command("INSERT INTO users (non_existant_field) VALUES ('Test')")
    lambda { command.execute_non_query }.should raise_error
  end
  
  it "should not have an insert_id without RETURNING" do    
    command = @connection.create_command("INSERT INTO users (name) VALUES ('Test')")
    result = command.execute_non_query
    result.insert_id.should == 0;
    result.to_i.should == 1;
  end
  
  it "should have an insert_id when RETURNING" do
    command = @connection.create_command("INSERT INTO users (name) VALUES ('Test') RETURNING id")
    result = command.execute_non_query
    result.insert_id.should_not == 0;
    result.to_i.should == 1;
  end
end