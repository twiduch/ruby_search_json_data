require 'minitest/spec'
require 'minitest/autorun'
require './gift_idea'

describe GiftIdea do
  let(:data) { File.read('data.json') }

  before do
    GiftIdea.input_data(data)
  end

  describe '.search' do
    it 'returns records which contain "Cake" in the title' do
      titles = GiftIdea.search('Cake').map(&:title)
      titles.must_include "3D Cake Moulds"
    end

    it 'returns records which contain "shoes" in the description' do
      descriptions = GiftIdea.search('shoes').map(&:description)
      descriptions.must_include "Great Shoes!"
    end
    
    it "returns [] when word is not included" do 
      result = GiftIdea.search('yoyo')
      result.must_be_empty
    end
    
    it "returns [] if search word is empty" do 
      result = GiftIdea.search('')
      result.must_be_empty      
    end
  end
  
  describe '.input_data' do 
    let(:ideas) {GiftIdea.instance_variable_get(:@ideas)}
    let(:index) {GiftIdea.instance_variable_get(:@index)}
    it "should have all ideas entered" do 
      ideas.size.must_equal 200
    end
    
    it "should have ideas as objects" do 
      ideas.first.must_be_instance_of(OpenStruct)
    end
     
    it "should have proper indexes" do 
      index.wont_be_empty
    end
  end
end
