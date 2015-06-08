module Unipept
  class Formatter
    # The Hash of available formatters
    #
    # @return [Hash] A hash of the available formatters
    def self.formatters
      @@formatters ||= {}
    end

    # Returns a new formatter of the given format. If the given format is not available, the
    # default formatter is returned
    #
    # @param [String] format The type of the formatter we want
    #
    # @return [Formatter] The requested formatter
    def self.new_for_format(format)
      formatters[format].new
    rescue
      formatters[default].new
    end

    # Adds a new formatter to the list of available formats
    #
    # @param [Symbol] format The type of the format we want to register
    def self.register(format)
      formatters[format.to_s] = self
    end

    # Returns a list of the available formatters
    #
    # @return [Array<String>] The list of available formatters
    def self.available
      formatters.keys
    end

    # @return [String] The type of the default formatter: csv
    def self.default
      'csv'
    end

    # @return [String] The type of the current formatter
    def type
      ''
    end

    # Returns the header row for the given sample_data and fasta_mapper. This
    # row is output only once at the beginning of the output
    #
    # @param [Object] _sample_data The data that we will output after this
    # header. Can be used to extract the keys.
    #
    # @param [Array<Array<String>>] _fasta_mapper Optional mapping between input
    # data and corresponding fasta header. The data is represented as a list
    # containing tuples where the first element is the fasta header and second
    # element is the input data
    #
    # @return [String] The header row
    def header(_sample_data, _fasta_mapper = nil)
      ''
    end

    # Converts the given input data and corresponding fasta headers to another
    # format.
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Array<Array<String>>] _fasta_mapper Optional mapping between input
    # data and corresponding fasta header. The data is represented as a list
    # containing tuples where the first element is the fasta header and second
    # element is the input data
    #
    # @return [String] The converted input data
    def format(data, _fasta_mapper = nil)
      data
    end
  end

  class JSONFormatter < Formatter
    require 'json'
    register :json

    # @return [String] The type of the current formatter: json
    def type
      'json'
    end

    # Converts the given input data and corresponding fasta headers to JSON.
    # Currently ignores the fasta_mapper.
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Array<Array<String>>] _fasta_mapper Optional mapping between input
    # data and corresponding fasta header. The data is represented as a list
    # containing tuples where the first element is the fasta header and second
    # element is the input data
    #
    # @return [String] The input data converted to the JSON format.
    def format(data, _fasta_mapper = nil)
      # TODO: add fasta header based on fasta_mapper information
      data.to_json
    end
  end

  class CSVFormatter < Formatter
    require 'csv'
    register :csv

    # @return [String] The type of the current formatter: csv
    def type
      'csv'
    end

    # Returns the header row for the given data and fasta_mapper. This row
    # contains all the keys of the first element of the data, preceded by
    # 'fasta_header' if a fasta_mapper is given.
    #
    # @param [Array] data The data that we will use to extract the keys from.
    #
    # @param [Array<Array<String>>] fasta_mapper Optional mapping between input
    # data and corresponding fasta header. The data is represented as a list
    # containing tuples where the first element is the fasta header and second
    # element is the input data If a fasta_mapper is given, the output will be
    # preceded with 'fasta_header'.
    #
    # @return [String] The header row
    def header(data, fasta_mapper = nil)
      CSV.generate do |csv|
        first = data.first
        keys = fasta_mapper ? ['fasta_header'] : []
        csv << (keys + first.keys).map(&:to_s) if first
      end
    end

    # Converts the given input data and corresponding fasta headers to the csv
    # format
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Array<Array<String>>] fasta_mapper Optional mapping between input
    # data and corresponding fasta header. The data is represented as a list
    # containing tuples where the first element is the fasta header and second
    # element is the input data
    #
    # @return [String] The converted input data into the csv format
    def format(data, fasta_mapper = nil)
      CSV.generate do |csv|
        if fasta_mapper
          format_fasta(csv, data, fasta_mapper)
        else
          format_normal(csv, data)
        end
      end
    end

    # Converts the given input data and corresponding fasta headers to the csv
    # format
    #
    # @param [CSV] csv object we write the csv output to
    #
    # @param [Array] data The data we wish to convert
    #
    # @return [String] The converted input data into the csv format
    def format_normal(csv, data)
      data.each do |o|
        csv << o.values.map { |v| v == ''  ? nil : v }
      end
    end

    # Converts the given input data and corresponding fasta headers to the csv
    # format
    #
    # @param [CSV] csv object we write the csv output to
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Array<Array<String>>] fasta_mapper Optional mapping between input
    # data and corresponding fasta header. The data is represented as a list
    # containing tuples where the first element is the fasta header and second
    # element is the input data
    #
    # @return [String] The converted input data into the csv format
    def format_fasta(csv, data, fasta_mapper)
      data_dict = group_by_first_key(data)
      fasta_mapper.each do |fasta_header, key|
        next if data_dict[key].nil?

        data_dict[key].each do |r|
          csv << ([fasta_header] + r.values).map { |v| v == '' ? nil : v }
        end
      end
    end

    # Groups the data by the first key of each element, for example
    # [{key1: v1, key2: v2},{key1: v1, key2: v3},{key1: v4, key2: v2}]
    # to {v1 => [{key1: v1, key2: v2},{key1: v1, key2: v3}], v4 => [{key1: v4, key2: v2}]]
    #
    # @param [Array<Hash>] data The data we wish to Groups
    #
    # @return [Hash] The input data grouped by the first key
    def group_by_first_key(data)
      data.group_by{|el| el.values.first.to_s}
    end
  end

  class XMLFormatter < Formatter
    # Monkey patch (do as to_xml, but saner)

    class ::Object
      def to_xml(name = nil)
        name ? %(<#{name}>#{self}</#{name}>) : to_s
      end
    end

    class ::Array
      def to_xml(array_name = :array, _item_name = :item)
        %(<#{array_name} size="#{size}">) + map { |n|n.to_xml(:item) }.join + "</#{array_name}>"
      end
    end

    class ::Hash
      def to_xml(name = nil)
        data = to_a.map { |k, v|v.to_xml(k) }.join
        name ? "<#{name}>#{data}</#{name}>" : data
      end
    end

    register :xml

    # @return [String] The type of the current formatter: xml
    def type
      'xml'
    end

    # Converts the given input data and corresponding fasta headers to XML.
    # Currently ignores the fasta_mapper.
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Array<Array<String>>] _fasta_mapper Optional mapping between input
    # data and corresponding fasta header. The data is represented as a list
    # containing tuples where the first element is the fasta header and second
    # element is the input data
    #
    # @return [String] The input data converted to the XML format.
    def format(data, _fasta_mapper = nil)
      # TODO: add fasta header based on fasta_mapper information
      data.to_xml
    end
  end
end
