require "spec_helper"

describe Replicat::Replicable do
  describe ".has_any_replication?" do
    context "with any replication in connection settings" do
      it "returns true" do
        Recipe.should have_any_replication
      end
    end
  end

  describe ".connection_with_proxy" do
    context "with non-replicable model" do
      it "returns normal connection" do
        User.connection.should_not be_a Replicat::Proxy
      end
    end

    context "with replicable model" do
      it "returns proxy object" do
        Recipe.connection.should be_a Replicat::Proxy
      end
    end
  end

  describe ".using" do
    context "with :master" do
      it "executes SQL query on master connection" do
        Recipe.create(title: "test")
        Recipe.using(:master) do
          Recipe.first.should_not == nil
        end
      end
    end

    context "with slave name" do
      after do
        Recipe.using(:slave1) do
          Recipe.destroy_all
        end
      end

      it "executes SQL query on specified slave" do
        Recipe.using(:slave1) do
          Recipe.create(title: "test")
        end
        Recipe.using(:slave1) do
          Recipe.first.should_not == nil
        end
        Recipe.using(:slave2) do
          Recipe.first.should == nil
        end
      end
    end
  end

  describe ".proxy" do
    it "prixies INSERT to master & SELECT to replications" do
      Recipe.create(title: "test")
      Recipe.first.should == nil
      Recipe.first.should == nil
      Recipe.first.should == nil
    end

    it "selects replications by roundrobin order" do
      Recipe.using(:slave1) do
        Recipe.create(title: "test")
      end
      Recipe.proxy.index = 0
      Recipe.first.should_not == nil
      Recipe.first.should == nil
      Recipe.first.should == nil
      Recipe.first.should_not == nil
      Recipe.first.should == nil
      Recipe.first.should == nil
      Recipe.first.should_not == nil
      Recipe.first.should == nil
      Recipe.first.should == nil
    end
  end
end
