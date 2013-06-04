module ObjectHelper
  def method_from_relation(object, relation)
    if relation.kind_of?(Hash)
      method_from_relation(proc { |object, method| object.send(method) }.call(object, relation.keys.first), relation.values.first)
    else
      send_to = proc { |object, method| object.send(method) }.call(object, relation)
      send_to = send_to.kind_of?(Array) ? send_to : [send_to]
    end
  end
end
