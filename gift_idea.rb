require './inv_index'

class GiftIdea
  class << self
    def search(term)
      @ideas.values_at(*@index.get_ids(term)) 
    end
    
    def input_data(json_data)
      parsed_data = JSON.parse(json_data)
      @ideas = parsed_data['gift_ideas'] 
      @index = InvIndex.new
      prepare_index
    end
    
    private
    def prepare_index
      @ideas.each_with_index do |idea, index|
        idea = idea['gift_idea']
        @ideas[index] = OpenStruct.new(idea)
        @index.index_data(idea['title'], index) if idea['title']
        @index.index_data(idea['description'], index) if idea['description']
      end
    end
  end
end

