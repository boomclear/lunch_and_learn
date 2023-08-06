require 'rails_helper'

RSpec.describe "Recipe Poro" do
  describe "Recipe Object attributes" do 
    it "Has attributes that are readable" do 
      recipe = Recipe.new("laos", {label: "Title", url: "url", image: "image"})

      expect(recipe.id).to eq("null")
      expect(recipe.title).to eq("Title")
      expect(recipe.url).to eq("url")
      expect(recipe.country).to eq("laos")
      expect(recipe.image).to eq("image")
    end
  end
end