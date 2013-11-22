require 'json'
require 'set'
require 'forwardable'

class InvIndex 
extend Forwardable

  def_delegators :@letter_index, :size, :to_s, :empty?

  NOT_AT_THE_END = %W(. \, \) \( - : ? ! ' ")
  NOT_AT_THE_FRONT = %W(' " \( \))
  NO_INDEX = %W(and the does don't for not) #those words will not be indexed
  MIN_LETTERS = 3  #minimum number of letters for word
  
  def initialize
    @letter_index = {}
  end
  
  def get_ids(word)
    word = clean_word(word.downcase)
    return if word.length < MIN_LETTERS || NO_INDEX.include?(word)
    
    letter_ind = get_letter_index(word[0].to_sym)
    letter_ind[word.to_sym]
  end
  
  def index_data(string_data, doc_id)
    string_data.split.each { |word| add_to_index(clean_word(word.downcase), doc_id) }
  end
  
  def add_to_index(word, doc_id)
    return if word.length < MIN_LETTERS || NO_INDEX.include?(word)
    
    first_letter = word[0].to_sym
    letter_ind = get_letter_index(first_letter)
    update_letter_index(letter_ind, word.to_sym, doc_id)
  end
  
  def clean_word(word)
    word.chop! while word.length>0 and NOT_AT_THE_END.include?(word[word.length-1]) 
    word = word[1..-1] while word.length>0 and NOT_AT_THE_FRONT.include?(word[0])
    word
  end
  
  def get_letter_index(letter_sym)
    @letter_index[letter_sym] = {} unless @letter_index[letter_sym] 
    @letter_index[letter_sym]
  end
  
  def update_letter_index(letter_ind, word_sym, doc_id)
    unless letter_ind[word_sym]
      letter_ind[word_sym] = Set.new [doc_id]
    else
      letter_ind[word_sym] << doc_id
    end
  end
end
