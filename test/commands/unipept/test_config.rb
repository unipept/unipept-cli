require_relative '../../../lib/commands'

module Unipept
  class UnipeptConfigTestCase < Unipept::TestCase
    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[config -h])
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[config --help])
        end
      end
      assert(out.include?('show help for this command'))
    end

    def test_no_args
      _out, err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[config])
        end
      end
      assert(err.include?('show help for this command'))
    end

    def test_too_many_args
      _out, err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[config a b c])
        end
      end
      assert(err.include?('show help for this command'))
    end

    def test_setting_config
      value = Random.rand.to_s
      config = Unipept::Configuration.new
      config.delete('test')
      config.save
      out, _err = capture_io_while do
        Commands::Unipept.run(['config', 'test', value])
      end
      assert_equal('test was set to ' + value, out.chomp)
      assert_equal(value, Unipept::Configuration.new['test'])
    end

    def test_getting_config
      value = Random.rand.to_s
      config = Unipept::Configuration.new
      config['test'] = value
      config.save
      out, _err = capture_io_while do
        Commands::Unipept.run(%w[config test])
      end
      config.delete('test')
      config.save
      assert_equal(value, out.chomp)
    end
  end
end
