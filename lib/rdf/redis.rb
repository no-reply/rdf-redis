require 'rdf'
require 'redis'
require 'enumerator'
require 'digest/md5'

module RDF
  class Redis < ::RDF::Repository
    class Enumerator < defined?(::Enumerable::Enumerator) ? ::Enumerable::Enumerator : ::Enumerator
    end

    VERSION = '0.0.2'

    STATEMENT_PREFIX = 'statements'

    SUBJECT_KEY   = 's'
    PREDICATE_KEY = 'p'
    OBJECT_KEY    = 'o'
    CONTEXT_KEY   = 'c'

    def initialize(options = {})
      @repository = options.delete(:name)
      @data = options.delete(:connection)
      @data ||= ::Redis.new(options)
    end

    # @see RDF::Enumerable#each_statement.
    def each(&block)
      if block_given?
        statement_keys.each do |statement|
          block.call(build(statement))
        end
      else
        Enumerator.new(self, :each)
      end
    end

    # @see RDF::Mutable#insert_statement
    def insert_statement(statement)
      key = key_for(statement)
      @data.multi do
        @data.mapped_hmset(key, {
          SUBJECT_KEY   => serialize(statement.subject),
          PREDICATE_KEY => serialize(statement.predicate),
          OBJECT_KEY    => serialize(statement.object),
          CONTEXT_KEY   => serialize(statement.context)
        })
      end
    end

    # @see RDF::Mutable#delete_statement
    def delete_statement(statement)
      @data.del(key_for(statement))
    end

    def has_statement?(statement)
      @data.exists(key_for(statement))
    end

    def count
      statement_keys.count
    end

    def clear
      return @data.flushdb if count == @data.size
      statement_keys.each do |key|
        redis.delete(key)
      end
    end

    private

    def build(statement)
      statement = @data.hgetall(statement)

      RDF::Statement.new(
                         :subject   => unserialize(statement[SUBJECT_KEY]),
                         :predicate => unserialize(statement[PREDICATE_KEY]),
                         :object    => unserialize(statement[OBJECT_KEY]),
                         :context   => unserialize(statement[CONTEXT_KEY])
                         )
    end

    def key_for(statement)
      "#{ key_prefix }:#{ Digest::MD5.hexdigest(statement.to_s) }"
    end

    def statement_keys
      @data.keys("#{ key_prefix }:*")
    end

    def key_prefix
      return "#{@repository}_#{STATEMENT_PREFIX}" if @repository
      return STATEMENT_PREFIX
    end

    def serialize(value)
      RDF::NTriples::Writer.serialize(value) || ''
    end

    def unserialize(value)
      value == '' ? nil : RDF::NTriples::Reader.unserialize(value)
    end
  end
end
