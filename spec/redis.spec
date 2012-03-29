$:.unshift '.'
require 'spec_helper'

require 'rdf'
require 'rdf/spec/repository'
require 'rdf/redis'

describe RDF::Redis do
  context 'Redis RDF Repository' do
    before do
      @repository = RDF::Redis.new() # TODO: Do you need constructor arguments?
      @repository.clear
    end

    after do
      @repository.clear
    end

    # @see lib/rdf/spec/repository.rb in RDF-spec
    it_should_behave_like RDF_Repository
  end

end

