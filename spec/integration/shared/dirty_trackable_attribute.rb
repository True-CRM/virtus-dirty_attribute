shared_examples_for "Dirty Trackable Attribute" do
  let(:model) do
    model = Class.new do
      include Virtus
      include Virtus::Dirty
    end

    model.attribute attribute_name, described_class
    model
  end

  context "when object is clean" do
    let(:object) do
      model.new
    end

    it "doesn't mark it as dirty" do
      object.dirty?.should be(false)
    end
  end

  context "when object is dirty" do
    let(:object) { model.new }

    it "should become clean again" do
      object[attribute_name] = attribute_value
      object.clean!

      object.should_not be_dirty

      object.original_attributes[attribute_name].should == attribute_value
      object.original_attributes.should == object.attributes
    end
  end

  context "when value is set on a new object" do
    let(:object) do
      model.new
    end

    before do
      object[attribute_name] = attribute_value
    end

    it "marks the object as dirty" do
      object.dirty?.should be(true)
    end

    it "marks the attribute as dirty" do
      object.attribute_dirty?(attribute_name).should be(true)
    end

    it "sets new value in dirty_attributes hash" do
      object.dirty_attributes[attribute_name].should == attribute_value
    end
  end

  context "when other value is set on a new object with attribute already set" do
    let(:object) do
      model.new(attribute_name => attribute_value)
    end

    let(:new_value) do
      model.attribute_set[attribute_name].coerce(attribute_value_other)
    end

    before do
      object[attribute_name] = new_value
    end

    it "marks the object as dirty" do
      object.dirty?.should be(true)
    end

    it "marks the attribute as dirty" do
      object.attribute_dirty?(attribute_name).should be(true)
    end

    it "sets new value in dirty_attributes hash" do
      object.dirty_attributes[attribute_name].should == new_value
    end

    it "sets original value" do
      object.original_attributes[attribute_name].should == attribute_value
    end
  end
end
