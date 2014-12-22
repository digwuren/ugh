#! /usr/bin/ruby -Ilib

require 'ugh'

require 'test/unit'

class Ughish < Ugh
end

class UghTests < Test::Unit::TestCase
  def test_everything
    e = Ugh.new 'harumph'
    assert e.is_a? Ugh
    assert e.is_a? Exception
    assert e.is_a? StandardError
    assert e.is_a? RuntimeError

    assert e.short_message.is_a? String
    assert_equal e.short_message, 'harumph'
    assert e.attributes.is_a? Hash
    assert e.attributes.empty?

    e = Ugh.new 'harrumph', to_wit: 'arrgh'
    assert_equal e.short_message, 'harrumph'
    assert_equal e.attributes.keys, [:to_wit]
    assert e[:to_wit].is_a? String
    assert_equal e[:to_wit], 'arrgh'
    assert e['to_wit'].is_a? String
    assert_equal e['to_wit'], 'arrgh'

    e[:during] = :mumbling
    assert_equal e.attributes.keys, [:to_wit, :during]
    assert_equal e[:during], :mumbling

    assert_equal e.to_s,
        'harrumph (to_wit: "arrgh", during: :mumbling)'
    assert_equal e.to_s(attributes_in_parentheses: false),
        'harrumph, to_wit: "arrgh", during: :mumbling'
    assert_equal e.inspect,
        '#<harrumph, to_wit: "arrgh", during: :mumbling>'

    e['loudness'] = :slight
    assert_equal e.attributes.keys,
        [:to_wit, :during, :loudness]
    assert_equal e[:loudness], :slight

    e.attributes = {:something_else => 'entirely'}
    assert_equal e.to_s, 'harrumph (something_else: "entirely")'

    e.short_message = 'rah-rah'
    assert_equal e.to_s, 'rah-rah (something_else: "entirely")'

    e.attributes.delete :something_else
    assert_equal e.to_s, 'rah-rah'

    assert_raise Ugh do
       ugh
    end

    assert_raise Ughish do
      ugh Ughish
    end

    begin
      ugh colour: 'yellow'
    rescue Ugh => e
      assert e.is_a? Ugh
      assert_equal e.attributes.keys, [:colour]
      assert_equal e[:colour], 'yellow'
    end

    begin
      ugh? bird: 'crow' do
        ugh colour: 'yellow'
      end
    rescue Ugh => e
      assert_equal e.attributes.keys, [:bird, :colour]
      assert_equal e[:bird], 'crow'
      assert_equal e[:colour], 'yellow'
    end

    begin
      ugh? bird: 'crow', colour: 'yellow' do
        ugh colour: 'purple'
      end
    rescue Ugh => e
      assert_equal e.attributes.keys, [:bird, :colour]
      assert_equal e[:bird], 'crow'
      assert_equal e[:colour], 'purple'
    end

    begin
      ugh? Ughish, bird: 'crow', colour: 'yellow' do
        ugh colour: 'purple'
      end
    rescue Ugh => e
      assert_equal e.attributes.keys, [:colour]
      assert_equal e[:bird], nil
      assert_equal e[:colour], 'purple'
    end

    assert_equal ugh?(bird: 'crow'){3}, 3

    begin
      i = 1
      counter_evaluated = false
      ugh? counter: proc{counter_evaluated = true; i} do
        i += 1
        ugh
        i += 1
      end
    rescue Ugh => e
      assert_equal counter_evaluated, true
      assert_equal e.attributes.keys, [:counter]
      assert_equal e[:counter], 2
    end

    begin
      i = 1
      counter_evaluated = false
      ugh? counter: proc{counter_evaluated = true; i} do
        i += 1
        ugh counter: 7
        i += 1
      end
    rescue Ugh => e
      assert_equal counter_evaluated, false
      assert_equal e.attributes.keys, [:counter]
      assert_equal e[:counter], 7
    end

    begin
      ugh? foo: 1 do
        ugh? bar: 2 do
          ugh? foo: 3 do
            ugh
          end
        end
      end
    rescue Ugh => e
      assert_equal e.attributes.keys, [:foo, :bar]
    end

    begin
      ugh? bar: 2 do
        ugh? foo: 3 do
          ugh
        end
      end
    rescue Ugh => e
      assert_equal e.attributes.keys, [:bar, :foo]
    end

    assert_raise Errno::ENOTDIR do
      File.read 'test-ugh.rb/file-that-can-not-exist'
    end

    begin
      File.read 'test-ugh.rb/file-that-can-not-exist'
    rescue StandardError => e
      assert e.respond_to? :strerror
      assert e.strerror.is_a? String
      assert_equal e.strerror, 'not a directory'
    end

    begin
      raise Errno::EBADRPC
    rescue StandardError => e
      assert_equal e.strerror, 'RPC struct is bad'
    end

    begin
      ugh? SystemCallError, filename: 'something/something' do
        File.read 'test-ugh.rb/file-that-can-not-exist'
      end
    rescue StandardError => e
      assert_equal e[:filename], 'something/something'
    end

    begin
      ugh? filename: 'something/something' do
        File.read 'test-ugh.rb/file-that-can-not-exist'
      end
    rescue StandardError => e
      assert_equal e[:filename], nil
    end

    return
  end
end
