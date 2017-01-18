require 'json'

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
      raise NotImplementedError, 'This must be implemented in a subclass.'
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
      raise NotImplementedError, 'This must be implemented in a subclass.'
    end

    # Returns the footer row. This row is output only once at the end of the
    # output
    #
    # @return [String] The footer row
    def footer
      raise NotImplementedError, 'This must be implemented in a subclass.'
    end

    # Converts the given input data and corresponding fasta headers to another
    # format.
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Array<Array<String>>] fasta_mapper Optional mapping between input
    # data and corresponding fasta header. The data is represented as a list
    # containing tuples where the first element is the fasta header and second
    # element is the input data
    #
    # @param [Boolean] Is this the first output batch?
    #
    # @return [String] The converted input data
    def format(data, fasta_mapper, first)
      data = integrate_fasta_headers(data, fasta_mapper) if fasta_mapper
      convert(data, first)
    end

    # Converts the given input data to another format.
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Boolean] Is this the first output batch?
    #
    # @return [String] The converted input data
    def convert(_data, _first)
      raise NotImplementedError, 'This must be implemented in a subclass.'
    end

    # Integrates the fasta headers into the data object
    def integrate_fasta_headers(data, fasta_mapper)
      data_dict = group_by_first_key(data)
      data = fasta_mapper.map do |header, key|
        result = data_dict[key]
        unless result.nil?
          result = result.map do |row|
            copy = { fasta_header: header }
            copy.merge(row)
          end
        end
        result
      end
      data.compact.flatten(1)
    end

    # Groups the data by the first key of each element, for example
    # [{key1: v1, key2: v2},{key1: v1, key2: v3},{key1: v4, key2: v2}]
    # to {v1 => [{key1: v1, key2: v2},{key1: v1, key2: v3}], v4 => [{key1: v4, key2: v2}]}
    #
    # @param [Array<Hash>] data The data we wish to group
    #
    # @return [Hash] The input data grouped by the first key
    def group_by_first_key(data)
      data.group_by { |el| el.values.first.to_s }
    end
  end

  class JSONFormatter < Formatter
    require 'json'
    register :json

    # @return [String] The type of the current formatter: json
    def type
      'json'
    end

    def header(_data, _fasta_mapper = nil)
      '['
    end

    def footer
      "]\n"
    end

    # Converts the given input data to the JSON format.
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Boolean] Is this the first output batch?
    #
    # @return [String] The converted input data in the JSON format
    def convert(data, first)
      output = data.map(&:to_json).join(',')
      first ? output : ',' + output
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

    def footer
      ''
    end

    # Converts the given input data to the CSV format.
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Boolean] Is this the first output batch?
    #
    # @return [String] The converted input data in the CSV format
    def convert(data, _first)
      CSV.generate do |csv|
        data.each do |o|
          csv << o.values.map { |v| v == '' ? nil : v }
        end
      end
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
        %(<#{array_name}>) + map { |n| n.to_xml(:item) }.join + "</#{array_name}>"
      end
    end

    class ::Hash
      def to_xml(name = nil)
        data = to_a.map { |k, v| v.to_xml(k) }.join
        name ? "<#{name}>#{data}</#{name}>" : data
      end
    end

    register :xml

    # @return [String] The type of the current formatter: xml
    def type
      'xml'
    end

    def header(_data, _fasta_mapper = nil)
      '<results>'
    end

    def footer
      "</results>\n"
    end

    # Converts the given input data to the XML format.
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Boolean] Is this the first output batch?
    #
    # @return [String] The converted input data in the XML format
    def convert(data, _first)
      data.map { |row| '<result>' + row.to_xml + '</result>' }.join('')
    end
  end

  class BlastFormatter < Formatter
    register :blast

    # @return [String] The type of the current formatter: blast
    def type
      'blast'
    end

    def header(_data, _fasta_mapper = nil)
      ''
    end

    def footer
      ''
    end

    # Converts the given input data to the Blast format.
    #
    # @param [Array] data The data we wish to convert
    #
    # @param [Boolean] Is this the first output batch?
    #
    # @return [String] The converted input data in the Blast format
    def convert(data, _first)
      data
        .reject { |o| o['refseq_protein_ids'].empty? }
        .map do |o|
          "#{o['peptide']}\tref|#{o['refseq_protein_ids']}|\t100\t10\t0\t0\t0\t10\t0\t10\t1e-100\t100\n"
        end
        .join
    end
  end
end
