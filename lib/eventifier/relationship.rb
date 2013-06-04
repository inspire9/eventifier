class Eventifier::Relationship
  def initialize(source, relation)
    @source, @relation = source, relation
  end

  def users
    Array object.send(method)
  end

  private

  attr_reader :relation, :source

  def object
    relation.is_a?(Hash) ? source.send(relation.keys.first) : source
  end

  def method
    relation.is_a?(Hash) ? relation.values.first : relation
  end
end
