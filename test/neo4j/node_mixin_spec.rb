$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../../lib")
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/..")

require 'neo4j'
require 'spec_helper'


# ----------------------------------------------------------------------------
# initialize
#

describe Neo4j::NodeMixin do
  before(:all) do
    delete_db
  end

  after(:all) do
    stop
  end

  describe '#initialize' do

    before(:each) do
      Neo4j::Transaction.new
    end

    after(:each) do
      Neo4j::Transaction.finish
    end

    it "should accept no arguments" do
      class TestNode1
        include Neo4j::NodeMixin
      end
      TestNode1.new
    end

    it "should allow to create a node from a native Neo Java object" do
      class TestNode4
        include Neo4j::NodeMixin
      end

      node1 = TestNode4.new
      node2 = TestNode4.new(node1._java_node)
      node1._java_node.should == node2._java_node
    end

    it "should take an hash argument to initialize its properties" do
      class TestNode6
        include Neo4j::NodeMixin
        property :foo
      end

      node1 = TestNode6.new :name => 'jimmy', :foo => 42
      node1.foo.should == 42
      node1[:name].should == 'jimmy'
    end

    it "should accept a block and pass self as parameter" do
      class TestNode5
        include Neo4j::NodeMixin
        property :foo
      end

      node1 = TestNode5.new {|n| n.foo = 'hi'}
      node1.foo.should == 'hi'
    end
  end


  describe '#init_node' do

    before(:each) do
      Neo4j::Transaction.new
    end

    after(:each) do
      Neo4j::Transaction.finish
    end

    it "should allow to initialize itself with one argument" do
      # given an initialize method
      class TestNode2
        include Neo4j::NodeMixin

        def init_node(arg1, arg2)
          self[:arg1] = arg1
          self[:arg2] = arg2
        end

      end

      # when
      n = TestNode2.new 'arg1', 'arg2'

      # then
      n[:arg1].should == 'arg1'
      n[:arg2].should == 'arg2'
    end


    it "should allow arguments for the initialize method" do
      class TestNode3
        include Neo4j::NodeMixin
        attr_reader :foo

        def init_node(value)
          @foo = value
          self[:name] = "Name #{value}"
        end
      end
      n = TestNode3.new 'hi'
      n.foo.should == 'hi'
      n[:name].should == "Name hi"
      id = n.neo_id
      p = Neo4j.load_node(id)
      p[:name].should == "Name hi"
      p.foo.should == nil
    end

    
  end

  describe '#equal' do
    class EqualNode
      include Neo4j::NodeMixin
    end

    before(:all) do
      start
    end

    before(:each) do
      Neo4j::Transaction.new
    end

    after(:each) do
      Neo4j::Transaction.finish
    end

    it "should be == another node only if it has the same node id" do
      node1 = EqualNode.new
      node2 = Neo4j.load_node(node1.neo_id)
      node2.should be_equal(node1)
      node2.should == node1
      node2.hash.should == node1.hash
    end

    it "should not be == another node only if it has not the same node id" do
      node1 = EqualNode.new
      node2 = EqualNode.new
      node2.should_not be_equal(node1)
      node2.should_not == node1
      node2.hash.should_not == node1
    end

  end

end

