class PancoreproteomeController < ApplicationController
  
  def analyze
    @species = Genome.get_genome_species()
    if params[:species_id]
      # return vars
      @cores = Array.new
      @pans = Array.new
      @genomes = Array.new
      @sims = Array.new
      
      # get all distinct refseq_ids
      refseqs = ActiveRecord::Base.connection.select_rows("select distinct straight_join bioproject_id, name, sequence_id from lineages left join uniprot_entries on lineages.taxon_id = uniprot_entries.taxon_id  left join refseq_cross_references on uniprot_entry_id = uniprot_entries.id  left join genomes on sequence_id = genomes.refseq_id  where species = #{params[:species_id]} and refseq_id IS NOT NULL")
      
      # vars used in the loop
      pan = Set.new
      core = nil
      sequences = Hash.new
      
      # group them by bioproject_id and calculate the pan and core numbers
      refseqs.group_by{|r| r[0]}.each do |k,v|
        @genomes << v[0][1]
        result = Set.new
        v.each do |r|
          result |= RefseqCrossReference.get_species_ids(r[2])
        end
        sequences[v[0][1]] = result
        pan |= result
        if core.nil?
          core = result
        else
          core &= result
        end
        @cores << core.size
        @pans << pan.size
      end
      
      @genomes.each_index do |i|
        @sims[i] = Array.new
      end
      @genomes.each_index do |i1|
        @genomes.each_index do |i2|
          if @sims[i1][i2].nil?
            sim = (sequences[@genomes[i1]] & sequences[@genomes[i2]]).length / (sequences[@genomes[i1]] | sequences[@genomes[i2]]).length.to_f
            @sims[i1][i2] = sim
            @sims[i2][i1] = sim
          end
        end
      end
      
      @sims2 = Array.new
      @sims.each {|e| @sims2 << Array.new(e)}
      active = Array.new
      @genomes.length.times do |i|
        active << i
      end
      
      joins = Array.new
      (@genomes.length-1).times do
        best = -1
        best_i = 0
        best_m = 0
        active.each do |i|
          active.each do |m|
            if i != m && @sims2[i][m] > best
              best = @sims2[i][m]
              best_i = i
              best_m = m
            end
          end
        end
        joins << [best_i, best_m]
        active.each do |j|
          avg = (@sims2[best_i][j] + @sims2[best_m][j])/2.0
          @sims2[best_i][j] = avg
          @sims2[j][best_i] = avg
        end
        active.delete best_m
      end
      order = joins.pop
      joins.reverse.each do |p|
        i = order.index p[0]
        order.insert(i, p[1])
      end
      @order = order
      
    else
      @genomes = ["Bacillus cereus ATCC 14579","Bacillus cereus ATCC 10987","Bacillus cereus E33L","Bacillus cereus NC7401","Bacillus cereus F837/76","Bacillus cereus Q1","Bacillus cereus G9842","Bacillus cereus B4264","Bacillus cereus AH187","Bacillus cereus AH820","Bacillus cereus 03BB102","Bacillus cereus biovar anthracis str. CI"]
      @cores = [92529, 45041, 39468, 37670, 36692, 34186, 33276, 32676, 31996, 31424, 31367, 30952]
      @pans = [92529, 138046, 168711, 187823, 204437, 226265, 240912, 247543, 258817, 266792, 267728, 273056]
      @sims = [[1.0, 0.32627529953783524, 0.3357319574086102, 0.3446071370231218, 0.3369803546464572, 0.3421801511290095, 0.4940569943979865, 0.6254490701606086, 0.3423888970913923, 0.34014699967089623, 0.3359142783751055, 0.34295293531672577], [0.32627529953783524, 1.0, 0.42602656306608394, 0.5012793596640861, 0.4158637169505897, 0.4988139891822681, 0.3238572465728074, 0.3400033038619273, 0.4985773335398713, 0.4254950704604752, 0.42301624129930393, 0.4234792504598884], [0.3357319574086102, 0.42602656306608394, 1.0, 0.47984408989091143, 0.5718651554581564, 0.48598267778067206, 0.3292607076216962, 0.34322155964624207, 0.4766864361830368, 0.5927722865966434, 0.5784618289166552, 0.6023452379907489], [0.3446071370231218, 0.5012793596640861, 0.47984408989091143, 1.0, 0.45759557142284085, 0.7576710102474771, 0.33385528805376136, 0.35257218232449067, 0.9518513349579706, 0.46535714571353165, 0.46277125864009, 0.480443584741734], [0.3369803546464572, 0.4158637169505897, 0.5718651554581564, 0.45759557142284085, 1.0, 0.4569740332824182, 0.334094505828028, 0.3480666200791987, 0.4578661786681797, 0.6218901083389209, 0.7763187331601934, 0.6170571545832515], [0.3421801511290095, 0.4988139891822681, 0.48598267778067206, 0.7576710102474771, 0.4569740332824182, 1.0, 0.3333066982413575, 0.35225470035252643, 0.7543262301583463, 0.46675173343605547, 0.4641166461019847, 0.48019684036706295], [0.4940569943979865, 0.3238572465728074, 0.3292607076216962, 0.33385528805376136, 0.334094505828028, 0.3333066982413575, 1.0, 0.5110119023635499, 0.33523413051176976, 0.33934828437191966, 0.33870944390554647, 0.3366028063583605], [0.6254490701606086, 0.3400033038619273, 0.34322155964624207, 0.35257218232449067, 0.3480666200791987, 0.35225470035252643, 0.5110119023635499, 1.0, 0.35355254316515233, 0.3525525873558556, 0.3477670170951969, 0.35492534897239864], [0.3423888970913923, 0.4985773335398713, 0.4766864361830368, 0.9518513349579706, 0.4578661786681797, 0.7543262301583463, 0.33523413051176976, 0.35355254316515233, 1.0, 0.4681696660149236, 0.4646283309957924, 0.47881742873915595], [0.34014699967089623, 0.4254950704604752, 0.5927722865966434, 0.46535714571353165, 0.6218901083389209, 0.46675173343605547, 0.33934828437191966, 0.3525525873558556, 0.4681696660149236, 1.0, 0.6198191541763423, 0.642337274916436], [0.3359142783751055, 0.42301624129930393, 0.5784618289166552, 0.46277125864009, 0.7763187331601934, 0.4641166461019847, 0.33870944390554647, 0.3477670170951969, 0.4646283309957924, 0.6198191541763423, 1.0, 0.6244128515062316], [0.34295293531672577, 0.4234792504598884, 0.6023452379907489, 0.480443584741734, 0.6170571545832515, 0.48019684036706295, 0.3366028063583605, 0.35492534897239864, 0.47881742873915595, 0.642337274916436, 0.6244128515062316, 1.0]]
      @order = [3, 8, 5, 4, 10, 9, 11, 2, 7, 0, 6, 1]
    end
  end
end