require "spec_helper"

describe Replicat::Model do
  let(:model_class) do
    Class.new(ActiveRecord::Base)
  end

  describe ".replicate" do
    context "with no args" do
      it "includes Replicat::Replicable" do
        model_class.replicate.ancestors.should include Replicat::Replicable
      end

      it "assigns connection_name attribute with Rails.env" do
        model_class.replicate.connection_name.should == Rails.env
      end

      it "returns itself" do
        model_class.replicate.should == model_class
      end
    end

    context "with args" do
      it "uses given value as connection_name attribute" do
        model_class.replicate("master1").connection_name.should == "master1"
      end
    end
  end

  describe ".replicated?" do
    context "with replicated model" do
      it "returns true" do
        model_class.replicate.should be_replicated
      end
    end

    context "with non-replicated model" do
      it "returns false" do
        model_class.should_not be_replicated
      end
    end
  end
end
