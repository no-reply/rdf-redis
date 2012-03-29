require 'rdf'
require 'redis'
require 'enumerator'
require 'digest/md5'

module RDF
  class Redis < ::RDF::Repository
    class Enumerator < defined?(::Enumerable::Enumerator) ? ::Enumerable::Enumerator : ::Enumerator
    end

    VERSION = '0.0.1'

    STATEMENT_PREFIX  = 'statements'
    STATEMENT_INDEX   = 'statements:index'
    STATEMENT_INDICES = {
      :subject   => 'subjects:index',
      :predicate => 'predicates:index',
      :object    => 'objects:index',
      :content   => 'contents:index'
    }

    SUBJECT_KEY   = 's'
    PREDICATE_KEY = 'p'
    OBJECT_KEY    = 'o'
    CONTEXT_KEY   = 'c'

    def initialize(options = {})
      @data = ::Redis.new(options)
    end

    # def query(pattern, &block)
    #   case pattern
    #   when Hash
    #     keys = pattern.map do |(k,v)|
    #       "#{ STATEMENT_INDICES[k.to_s] }:#{ v }" unless v.nil?
    #     end.compact

    #     @data.sinter(keys).map do |statement|
    #       _build(statement)
    #     end
    #   else
    #     super(pattern)
    #   end
    # end

    # @see RDF::Enumerable#each_statement.
    def each(&block)
      if block_given?
        _statment_keys.each do |statement|
          block.call(_build(statement))
        end
      else
        Enumerator.new(self, :each)
      end
    end

    # @see RDF::Mutable#insert_statement
    def insert_statement(statement)
      key = _key_for(statement)

      @data.multi do
        @data.mapped_hmset(key, {
          SUBJECT_KEY   => _serialize(statement.subject),
          PREDICATE_KEY => _serialize(statement.predicate),
          OBJECT_KEY    => _serialize(statement.object),
          CONTEXT_KEY   => _serialize(statement.context)
        })

        # _build_inverse_index_for(statement, key)
      end
    end

    # @see RDF::Mutable#delete_statement
    def delete_statement(statement)
      @data.del(_key_for(statement))
    end

    def has_statement?(statement)
      @data.exists(_key_for(statement))
    end

    def count
      _statment_keys.count
    end

    def clear
      @data.flushdb
    end

    private
      def _build(statement)
        statement = @data.hgetall(statement)

        RDF::Statement.new(
          :subject   => _unserialize(statement[SUBJECT_KEY]),
          :predicate => _unserialize(statement[PREDICATE_KEY]),
          :object    => _unserialize(statement[OBJECT_KEY]),
          :context   => _unserialize(statement[CONTEXT_KEY])
        )
      end

      # def _build_inverse_index_for(statement, key)
      #   statement.to_hash.each do |k, v|
      #     @data.sadd("#{ STATEMENT_INDICES[k] }:#{ v }", key) unless v.nil?
      #   end
      # end

      def _key_for(statement)
        "#{ STATEMENT_PREFIX }:#{ Digest::MD5.hexdigest(statement.to_s) }"
      end

      def _statment_keys
        @data.keys("#{ STATEMENT_PREFIX }:*")
      end

      def _serialize(value)
        RDF::NTriples::Writer.serialize(value) || ''
      end

      def _unserialize(value)
        value == '' ? nil : RDF::NTriples::Reader.unserialize(value)
      end
  end
end
