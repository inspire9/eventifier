module ModelHelpers
  def self.included(base)
    base.instance_eval do
      extend ModelHelpers::ClassMethods
    end
  end

  module ClassMethods
    def it_requires_a(attribute)
      it "requires a #{attribute}" do
        instance = Fabricate.build(self.class.described_class.name.demodulize.downcase.to_sym, attribute => nil)
        instance.errors[attribute].should_not be_nil
      end
    end

    def it_requires_an(attribute)
      it "requires an #{attribute}" do
        instance = Fabricate.build(self.class.described_class.name.demodulize.downcase.to_sym, attribute => nil)
        instance.errors[attribute].should_not be_nil
      end
    end
  end
end

RSpec.configure do |config|
  config.include ModelHelpers
end

RSpec::Matchers.define(:require_a) do |attribute|
  description { "require the presence of a #{attribute.to_s}" }
  match { |instance|
    instance.send("#{attribute}=", nil)
    instance.save
    !instance.errors[attribute.to_sym].empty?
  }
end
