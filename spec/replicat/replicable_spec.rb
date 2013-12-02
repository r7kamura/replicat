require "spec_helper"

describe Replicat::Replicable do
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
        Recipe.using(:master).first.should_not == nil
      end
    end

    context "with slave name" do
      after do
        Recipe.using(:slave1).destroy_all
      end

      it "executes SQL query on specified slave" do
        Recipe.using(:slave1).create(title: "test")
        Recipe.using(:slave1).first.should_not == nil
        Recipe.using(:slave2).first.should == nil
      end
    end

    context "with block" do
      it "forces the receiver to use specified connection in the passed block" do
        Recipe.using(:slave1).create(title: "test")
        Recipe.using(:slave1) { Recipe.first.should_not == nil }
      end
    end

    context "with no block" do
      it "can be used as scope" do
        Recipe.using(:slave1).create(title: "test")
        Recipe.using(:slave1).first.should_not == nil
      end
    end

    context "with scope" do
      it "works well" do
        Recipe.all.using(:slave1).create(title: "test")
        Recipe.where(title: "test").using(:slave1).first.should_not == nil
      end
    end

    context "with belongs_to association" do
      let!(:ingredient) do
        Ingredient.using(:slave1).create(name: "test", recipe_id: recipe.id)
      end

      let(:recipe) do
        Recipe.using(:slave1).create(title: "test")
      end

      it "works well" do
        Recipe.using(:slave1) { ingredient.recipe.should == recipe }
      end
    end

    context "with has_many association" do
      let!(:ingredient) do
        Ingredient.using(:slave1).create(name: "test", recipe_id: recipe.id)
      end

      let(:recipe) do
        Recipe.using(:slave1).create(title: "test")
      end

      it "works well" do
        Ingredient.using(:slave1) { recipe.ingredients.should == [ingredient] }
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
      Recipe.using(:slave1).create(title: "test")
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
