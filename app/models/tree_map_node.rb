class TreeMapNode < Node
  #:metadata contains the sequences
  attr_accessor :state, :metadata, :attr
  
  GRADIENT = ["#382413", "#3D3111", "#42420E", "#36440B", "#284907", "#33590E", "#406617", "#4D7522", "#5B822E", "#718E3B", "#879B4A", "#9DA85A", "#B0B26B", "#BFB97E", "#CCC192", "#D8CAA9"]
  
  def initialize(id, name, rank="")
    super(id, name)
    
    #area
    @data[:$area] = 0
    @data[:count] = 0
    
    @metadata = Hash.new
    @metadata[:all_sequences] = Array.new
    
    @attr = Hash.new
    @attr[:title] = rank
    
    #color
    @data[:level] = 0
    @data[:$color] = GRADIENT[@data[:level]]
    
    fix_title_and_state
  end
  
  # adds a child to this node and updates the color of the child
  # returns the added child
  def add_child(child, root)
    child.data[:level] = @data[:level]+1 if @data[:level] < GRADIENT.size
    child.data[:$color] = GRADIENT[child.data[:level]]
    super(child, root)
  end
  
  # adds a number to the count variable and recalculates the area
  def add_sequences(sequences)
    @metadata[:all_sequences].concat(sequences) 
    
    @data[:count] += sequences.length
    @data[:$area] = Math.log10(@data[:count]+1)/Math.log10(2)
    
    fix_title_and_state
  end
  
  def add_own_sequences(sequences)
    @data[:self_count] = sequences.length
    @metadata[:own_sequences] = sequences
  end
  
  def fix_title_and_state
    @data[:title] = @name
    if @children.length != 0
      @data[:title] += " (" + (@data[:self_count].nil? ? "0" : @data[:self_count].to_s) + "/" + @data[:count].to_s + ")" 
    else
      @data[:title] += " (" + @data[:count].to_s + ")" 
    end
      
    @state = @data[:level] <= 3 ? "open" : "closed"
  end
end