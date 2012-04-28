require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/import_base.rb')

describe CSVImporter::AdminsOfSchools do
  it_should_behave_like "csv importer"
  describe "importer"  do
    it 'should not touch anything missing a district_user_id' do
      @user = Factory(:user, :district_user_id => 2)
      @school = Factory(:school, :district => @user.district)
      @user.user_school_assignments.create!(:admin => true, :school_id => @school.id)
      @usa = @user.user_school_assignments
      @district = @user.district
      #school2
      @i=CSVImporter::AdminsOfSchools.new "#{Rails.root}/spec/csv/user_school_assignments.csv",@district
      @i.import

      @user.user_school_assignments.reload.should == @usa
    end
    it 'should not touch anything missing a district_school_id' do
      @user = Factory(:user)
      @school = Factory(:school, :district_school_id => 2 , :district => @user.district)
      @user.user_school_assignments.create!(:admin => true, :school_id => @school.id)
      @usa = @user.user_school_assignments
      @district = @user.district
      #school2
      @i=CSVImporter::AdminsOfSchools.new "#{Rails.root}/spec/csv/user_school_assignments.csv",@district
      @i.import

      @school.user_school_assignments.reload.should == @usa
    end

    it 'should not touch matching keys in another district'
    it 'should not remove anything from another district'
    it 'should add a role and userschool assignment if in the file but not in system'
    it 'should just add the assignment if the role is already in the system'
    it 'should add just the role if the assignment is already in the system and in the file'
    it 'should remove the assignment if it is in the system but not the file'



    it 'should work properly' do
      #be sure to test with existing admin
      School.delete_all
      UserSchoolAssignment.delete_all
      District.delete_all
      User.delete_all


      @no_role_or_district_user_id = Factory(:user)
      @district = @no_role_or_district_user_id.district
      @school_no_link = Factory(:school, :district_id => @district.id)
      @school_with_link = Factory(:school, :district_id => @district.id, :district_school_id => 2)
      @school_with_link_admin = Factory(:user, :district_id => @district.id, :district_user_id => 'school_with_link_admin')
      @school_with_link_admin.user_school_assignments.create!(:school_id => @school_with_link.id, :admin => true)
      @school_with_link_admin2 = Factory(:user, :district_id => @district.id, :district_user_id => 'school_with_link_admin2')
      @school_with_link_admin2.user_school_assignments.create!(:school_id => @school_with_link.id, :admin => true)

      @no_role_or_district_user_id.user_school_assignments.create!(:school_id => @school_no_link.id)


      @role_no_district_user_id = Factory(:user,:district_id => @district.id)
      @should_lose_role = Factory(:user,:district_id => @district.id,  :district_user_id => 'should_lose_role')
      @should_keep_role = Factory(:user,:district_id => @district.id,  :district_user_id => 'should_keep_role')
      @should_keep_no_role = Factory(:user,:district_id => @district.id, :district_user_id => 'should_keep_no_role')
      @should_gain_role = Factory(:user,:district_id => @district.id, :district_user_id => 'should_gain_role')
      @dup_person_id = Factory(:user,:district_id => @district.id, :district_user_id => @should_gain_role.district_user_id)
      @dup_person_id.user_school_assignments.create!(:school_id => @school_no_link.id)
      [@role_no_district_user_id, @should_lose_role, @should_keep_role].each do |u|
        u.user_school_assignments.create!(:school_id => @school_with_link.id)
      end


      @role_no_district_user_id.user_school_assignments.create!(:school_id => @school_no_link.id)
      @district.users.update_all("updated_at = '2000-01-01'")
      @i=CSVImporter::UserSchoolAssignments.new "#{Rails.root}/spec/csv/user_school_assignments.csv",@district
      @i.import

      @school_with_link_admin.reload.user_school_assignments.collect(&:admin).should == [true]
      @school_with_link_admin2.reload.user_school_assignments.collect(&:admin).should == [true]


      @no_role_or_district_user_id.reload.user_school_assignments.size.should == 1
      @no_role_or_district_user_id.user_school_assignments.find_all_by_school_id(@school_no_link.id).size.should == 1

      @should_lose_role.reload.user_school_assignments == []
      @should_keep_no_role.user_school_assignments.should == []

      [@should_keep_role,@should_gain_role].each{|u| check_user_school_assignments u}
      @dup_person_id.reload.user_school_assignments.count.should == 2

      @dup_person_id.school_ids.to_set.should == [@school_no_link.id, @school_with_link.id].to_set
      @dup_person_id.user_school_assignments.collect(&:school_id).to_set.should == [@school_no_link.id, @school_with_link.id].to_set

      @role_no_district_user_id.school_ids.to_set.should == [@school_no_link.id, @school_with_link.id].to_set
      @role_no_district_user_id.user_school_assignments.collect(&:school_id).to_set.should == [@school_no_link.id, @school_with_link.id].to_set
    end

    def check_user_school_assignments u
      u.reload.user_school_assignments.size.should == 1
      u.user_school_assignments.find_all_by_school_id(@school_with_link).size.should == 1
    end

  end
end




