require_relative '../lib/configuration'

module Unipept
  class ConfigurationTestCase < Unipept::TestCase
    def test_load_without_file
      config = Configuration.new('no_file')
      assert_equal({}, config.config)
    end

    def test_load_with_file
      hash = { 'key' => 'value' }
      File.write('new_file', hash.to_yaml)
      config = Configuration.new('new_file')
      assert_equal(hash, config.config)
    end

    def test_save
      file_name = 'no_file'
      assert(!(File.exist? file_name))
      config = Configuration.new(file_name)
      config.config['key'] = 'value'
      config.save
      assert((File.exist? file_name))
      other_config = Configuration.new(file_name)
      assert_equal('value', other_config.config['key'])
    end

    def test_assign
      config = Configuration.new('no_file')
      config['key'] = 'value'
      assert_equal('value', config.config['key'])
      assert_equal('value', config['key'])
    end

    def test_delete
      config = Configuration.new('no_file')
      config['key'] = 'value'
      assert_equal('value', config['key'])
      config.delete('key')
      assert_equal(nil, config['key'])
    end
  end
end
