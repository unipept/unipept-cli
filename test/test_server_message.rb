require_relative '../lib/server_message'

module Unipept
  class ServerMessageTestCase < Unipept::TestCase
    def test_init
      assert_equal('http://test_host/api/v1/messages.json', ServerMessage.new('http://test_host').message_url)
    end

    def test_fetch_server_message
      server = ServerMessage.new('http://api.unipept.ugent.be')
      assert(!server.fetch_server_message.nil?)
    end

    def test_print_server_message
      server = ServerMessage.new('http://api.unipept.ugent.be')
      server.stub(:recently_fetched?, false) do
        server.stub(:fetch_server_message, 'message') do
          out, _err = capture_io_while do
            def $stdout.tty?
              true
            end
            server.print
          end
          assert_equal('message', out.chomp)
        end
      end
    end

    def test_empty_print_server_message
      server = ServerMessage.new('http://api.unipept.ugent.be')
      server.stub(:recently_fetched?, false) do
        server.stub(:fetch_server_message, '') do
          out, _err = capture_io_while do
            def $stdout.tty?
              true
            end
            server.print
          end
          assert_equal('', out)
        end
      end
    end

    def test_recent_print_server_message
      server = ServerMessage.new('http://api.unipept.ugent.be')
      server.stub(:recently_fetched?, true) do
        server.stub(:fetch_server_message, 'message') do
          out, _err = capture_io_while do
            def $stdout.tty?
              true
            end
            server.print
          end
          assert_equal('', out)
        end
      end
    end

    def test_no_tty_print_server_message
      server = ServerMessage.new('http://api.unipept.ugent.be')
      server.stub(:recently_fetched?, false) do
        server.stub(:fetch_server_message, 'message') do
          out, _err = capture_io_while do
            def $stdout.tty?
              false
            end
            server.print
          end
          assert_equal('', out)
        end
      end
    end

    def test_never_recently_fetched
      server = ServerMessage.new('http://api.unipept.ugent.be')
      server.configuration.delete('last_fetch_date')
      assert(!server.recently_fetched?)
    end

    def test_old_recently_fetched
      server = ServerMessage.new('http://api.unipept.ugent.be')
      server.configuration['last_fetch_date'] = Time.now - (60 * 60 * 25)
      assert(!server.recently_fetched?)
    end

    def test_recently_recently_fetched
      server = ServerMessage.new('http://api.unipept.ugent.be')
      server.configuration['last_fetch_date'] = Time.now - (60 * 60 * 1)
      assert(server.recently_fetched?)
    end
  end
end
