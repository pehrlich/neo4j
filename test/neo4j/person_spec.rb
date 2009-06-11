$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../../lib")
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/..")

require 'neo4j'
require 'neo4j/spec_helper'



describe "Person" do
  before(:all) do
    start
    undefine_class :Person

    class Person
      include Neo4j::NodeMixin
      property :name, :age
      has_n :friends
      index :name
      index :'friends.age'
    end
  end

  after(:all) do
    stop
  end  
  
  it "should be possible to create a new instance" do
    person = Person.new
    result = Neo4j.instance.find_node person.neo_node_id
    result.should == person
  end

  it "should find persons who has friends with a specific age" do
    me = Person.new
    me.age = 10
    you = Person.new
    you.age = 20

    me.friends << you
    
    # when
    res = Person.find('friends.age' => '20')

    # then
    res.size.should == 1
    res[0].should == me
  end

  it "should be possible to find it given its name" do
    person1 = Person.new
    person1.name = 'kalle'
    person2 = Person.new
    person2.name = "sune"

    # when
    result = Person.find(:name => 'kalle')
    
    # then
    result.should include(person1)
    result.should_not include(person2)
    result.size.should == 1
  end
  
  
  it "should be possible to add a friend" do
    person1 = Person.new
    person1.name = 'kalle'
    
    person2 = Person.new
    person2.name = "sune"
    
    # when
    person1.friends << person2
    
    # then
    person1.friends.to_a.should include(person2)
  end


  it "should be possible to remove a friend" do
    # given
    person1 = Person.new
    person1.name = 'kalle'
    person2 = Person.new
    person2.name = "sune"
    person1.friends << person2

    # when
    person1.relationships[person2].delete
    
    # then
    person1.friends.to_a.should_not include(person2)
  end
  
end

