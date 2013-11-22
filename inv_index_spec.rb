require 'minitest/spec'
require 'minitest/autorun'
require './inv_index'

describe InvIndex do
  let(:data) { File.read('data.json') }
  let(:index) {InvIndex.new}
  
  it "should properly initialize" do
    index.instance_variable_get(:@letter_index).must_be_empty
  end
  
  describe "#clean_word" do 
    it "should remove unproper characters from the end of the word" do 
      index.clean_word('kok...').must_equal 'kok'
      index.clean_word('as:').must_equal 'as'
    end
    it "should return empty string if word is built from unproper characters" do 
      index.clean_word('...').must_equal ''
    end   
    it "should return original string if word is built from proper characters" do 
      index.clean_word('word').must_equal 'word'
    end      
    
    it "should remove ' " do 
      index.clean_word("'word'").must_equal "word"
    end
    
    it 'should remove " ' do 
      index.clean_word('"word"').must_equal 'word'
    end    
  end
  
  describe "#get_letter_index" do 
    before do 
      index.instance_variable_set(:@letter_index, {:m => {:mobile => Set.new}})
    end
    it "should return empty hash if symbol does not exist" do
      index.get_letter_index(:a).must_equal({})
    end
     it "should return filled hash if symbol already exists" do
      index.get_letter_index(:m).must_equal({:mobile=> Set.new})
    end   
  end
  
  describe "#update_letter_index" do 
    let(:letter_ind) {{:mobile => Set.new}}
    let(:empty_ind) {{}}
    
    it "should return new set included if word is not indexed" do 
      index.update_letter_index(letter_ind, :moon, 5)
      letter_ind.must_equal({:mobile=>Set.new, :moon=>Set.new([5])})
    end
    
    it "should return new set included if hash is empty" do 
      index.update_letter_index(empty_ind, :moon, 1)
      empty_ind.must_equal({:moon=>Set.new([1])})
    end
  end
  
  describe "#add_to_index" do 
    it "should do nothing if word is not to be indexed" do 
      index.add_to_index('does', 5)
      index.instance_variable_get(:@letter_index).must_be_empty
    end

    it "should do nothing if word has no proper number of letters" do 
      index.add_to_index('I', 5)
      index.instance_variable_get(:@letter_index).must_be_empty
    end  
    
     it "should add indexed word to proper hash only once" do 
      index.add_to_index('horse', 5)
      index.instance_variable_get(:@letter_index).must_equal({:h => {:horse=>Set.new([5])}})
      index.add_to_index('horse', 5)
      index.instance_variable_get(:@letter_index).must_equal({:h => {:horse=>Set.new([5])}})      
    end     
    
     it "should add indexed word to proper hash and set proper documents ids" do 
      index.add_to_index('horse', 5)
      index.instance_variable_get(:@letter_index).must_equal({:h => {:horse=>Set.new([5])}})
      index.add_to_index('horse', 3)
      index.instance_variable_get(:@letter_index).must_equal({:h => {:horse=>Set.new([5,3])}})  
      index.add_to_index('horse', 3)
      index.instance_variable_get(:@letter_index).must_equal({:h => {:horse=>Set.new([5,3])}})           
    end   
    
     it "should add indexed words to proper hashes and set proper documents ids" do 
      index.add_to_index('horse', 5)
      index.instance_variable_get(:@letter_index).must_equal({:h => {:horse=>Set.new([5])}})
      index.add_to_index('mambo', 3)
      index.instance_variable_get(:@letter_index).must_equal({:h => {:horse=>Set.new([5])}, :m => {:mambo=>Set.new([3])}})  
      index.add_to_index('more', 3)
      index.instance_variable_get(:@letter_index).must_equal({:h => {:horse=>Set.new([5])}, :m => {:mambo=>Set.new([3]), :more=>Set.new([3])}})  
      index.add_to_index('mambo', 1)
      index.instance_variable_get(:@letter_index).must_equal({:h => {:horse=>Set.new([5])}, :m => {:mambo=>Set.new([3,1]), :more=>Set.new([3])}})               
    end              
  end
  
  describe "#index_data" do 
  
    before {index.index_data("one more time", 1)}
    
    it "should add words from string to proper hashes" do 
      index.instance_variable_get(:@letter_index).must_equal({:o => {:one=>Set.new([1])}, :m => {:more=>Set.new([1])}, :t => {:time=>Set.new([1])}})    
    end    
    
    it "should update properly indexes" do
      index.index_data(" Again One MORE time.", 2)
      index.instance_variable_get(:@letter_index).must_equal({:o => {:one=>Set.new([1,2])}, :m => {:more=>Set.new([1,2])}, :t => {:time=>Set.new([1,2])}, :a => {:again=>Set.new([2])}})         
    end
    
    it "should do nothing if string is empty" do 
      index.index_data("", 1)
      index.instance_variable_get(:@letter_index).must_equal({:o => {:one=>Set.new([1])}, :m => {:more=>Set.new([1])}, :t => {:time=>Set.new([1])}}) 
    end
  end
  
  describe "#get_ids" do 
    before do 
      index.index_data("one more time", 1)
      index.index_data("Again. One more time!", 5)
    end 
    
    it "should return proper document ids for correct word" do 
      index.get_ids('more').must_equal Set.new([1,5])
    end
    
    it "should not be case sensitive" do 
      index.get_ids('aGaIn').must_equal Set.new([5])       
    end
    
    it "should not take improper characters into consideration" do 
      index.get_ids('aGaIn!').must_equal Set.new([5])              
    end
    
    it "should return nil for non existing word" do 
      index.get_ids('lost').must_be_nil          
    end
  end
end
