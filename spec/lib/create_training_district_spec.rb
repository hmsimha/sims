require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CreateTrainingDistrict do
  describe 'generate_one class method' do
    before :all do
      GoalDefinition.delete_all
      ProbeDefinition.delete_all
      @district = CreateTrainingDistrict.generate_one
    end
    it 'should generate a training district' do
      @district.abbrev.should == 'training'
    end
    it 'should have one checklist definition' do
      @district.checklist_definitions.count.should == 1
    end
  end
end
