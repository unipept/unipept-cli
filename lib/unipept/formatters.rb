module Unipept
  class Formatter

    def self.formatters
      @@formatters ||= {}
    end

    def self.new_for_format(format)
      begin
        formatters[format].new
      rescue
        formatters[self.default].new
      end
    end

    def self.register(format)
      self.formatters[format.to_s] = self
    end

    def self.available
      self.formatters.keys
    end

    def self.default
      'csv'
    end

    def header(sample_data, fasta_mapper = nil)
      ""
    end

    # JSON formatted data goes in, something other comes out
    def format(data, fasta_mapper = nil)
      data
    end
  end

  class JSONFormatter < Formatter
    require 'json'
    register :json

    def format(data, fasta_mapper = nil)
      # TODO: add fasta header based on fasta_mapper information
      data.to_json
    end

  end
  class CSVFormatter < Formatter
    require 'csv'

    register :csv

    def header(data, fasta_input = nil)
      CSV.generate do |csv|
        first = data.first
        if first.kind_of? Array
          first = first.first
        end
        if fasta_input
          csv << (['fasta_header'] + first.keys).map(&:to_s) if first
        else
          csv << first.keys.map(&:to_s) if first
        end
      end
    end

    def format(data, fasta_input = nil)
      CSV.generate do |csv|

        if fasta_input
          # Process the output from {key1: value1, key2: value2, ...}
          # to {value => {key1: value1, key2: value2, ...}}
          data_dict = {}
          data.each do |d|
            data_dict[d.values.first.to_s] ||= []
            data_dict[d.values.first.to_s] << d
          end

          # Iterate over the input
          fasta_input.each do |input_pair|
            fasta_header, id = input_pair

            # Retrieve the corresponding API result (if any)
            unless data_dict[id].nil?
              data_dict[id].each do |r|
                csv << ([fasta_header] + r.values).map { |v| v == "" ? nil : v }
              end
            end
          end

        else

          data.each do |o|
            csv << o.values.map { |v| v == ""  ? nil : v }
          end

        end
      end
    end
  end

  class XMLFormatter < Formatter

    # Monkey patch (do as to_xml, but saner)

    class ::Object
      def to_xml(name = nil)
        name ? %{<#{name}>#{self.to_s}</#{name}>} : self.to_s
      end
    end

    class ::Array
      def to_xml(array_name = :array, item_name = :item)
        %|<#{array_name} size="#{self.size}">| + self.map{|n|n.to_xml( :item )}.join+"</#{array_name}>"
      end
    end

    class ::Hash
      def to_xml(name = nil)
        data = to_a.map{|k,v|v.to_xml(k)}.join
        name ? "<#{name}>#{data}</#{name}>" : data
      end
    end

    register :xml

    def format(data, fasta_mapper = nil)
      # TODO: add fasta header based on fasta_mapper information
      data.to_xml
    end

  end


end
