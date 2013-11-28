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

  describe ".proxy" do
    it "proxies SELECT statement to one of the replication connections" do
      # This should return false because the test_slave1.sqlite3 does not have any table.
      Recipe.table_exists?.should == false
    end
  end
end
