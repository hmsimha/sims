# == Schema Information
# Schema version: 20090623023153
#
# Table name: users
#
#  id           :integer(4)      not null, primary key
#  username     :string(255)
#  passwordhash :binary
#  first_name   :string(255)
#  last_name    :string(255)
#  district_id  :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  email        :string(255)
#  middle_name  :string(255)
#  suffix       :string(255)
#  salt         :string(255)     default("")
#  id_district  :integer(4)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:all) do
    @user = User.find_by_username 'oneschool' 
    @user ||= Factory(:user, :username => "oneschool")
  end

  describe 'authenticate' do
    it 'should find user with valid login and password' do
      u = User.authenticate('oneschool', 'oneschool')
      u.username.should == 'oneschool'
    end
  
    it 'should not allow bad password' do
      User.authenticate('oneschool', 'badpass').should be_nil
    end
  
    it 'should not allow bad login' do
      User.authenticate('doesnotexist', 'ignored').should be_nil
    end

    describe 'additional hash keys and salts' do
      before do
        System::HASH_KEY='mms'
      end

      describe 'allowed_password_hashes' do
        it 'should cover all possibilities'  do
          district = Factory(:district, :key => dk='ddd_kk', :previous_key => next_dk = 'eee_ll')
          salt = 'Salt'
          u = Factory(:user, :district => district, :salt => salt)
          password='zow#3vVc'.downcase

          pnn = Digest::SHA1.hexdigest("#{password}#{salt}")
          pns = Digest::SHA1.hexdigest("#{System::HASH_KEY}#{password}#{salt}")
          ppn = Digest::SHA1.hexdigest("#{password}#{next_dk}#{salt}") 
          pps = Digest::SHA1.hexdigest("#{System::HASH_KEY}#{password}#{next_dk}#{salt}")
          pdn = Digest::SHA1.hexdigest("#{password}#{dk}#{salt}") 
          pds = Digest::SHA1.hexdigest("#{System::HASH_KEY}#{password}#{dk}#{salt}")
          
          u.allowed_password_hashes(password).should == [pnn, pns, pdn, pds, ppn, pps]
        end
      end

      it 'should call allowed passwordhashes' do
        @user.should_receive(:allowed_password_hashes).with('fail').and_return([])
        User.should_receive(:find_by_username).with('oneschool').and_return(@user)
        # User.any_instance.should_receive(:allowed_password_hashes).with('fail')
        User.authenticate('oneschool','fail')
        
      end

      
      it 'should store new users passwords including system hash_key when present' do
        u = Factory(:user, :password => 'test')
        u.passwordhash.should == User.encrypted_password("#{System::HASH_KEY}test", u.salt, nil, nil)
      end

      it 'should generate a salt when a user sets a password' do
        d = Factory(:district, :key => 'DisKye')
        u = Factory(:user, :password => 'motest', :district => d)
        u.salt.should_not be_blank
      end

      it 'should generate different salts for 2 different users' do
        u1 = Factory(:user)
        u2 = Factory(:user)
        u1.salt.should_not == u2.salt
      end

      it 'should change the salt when a password is changed on an existing record if a different salt has not been passed in' do
        u1 = Factory(:user)
        oldsalt = u1.salt

        u1.password='SOEMWEWEE'
        u1.salt.should_not == oldsalt
      end

      it 'should not change the salt when a password is changed at the same time a salt is explicitly passed in' do
        u1 = Factory(:user)
        oldsalt = u1.salt

        u1.update_attributes(:password => 'SOEMWEWEE', :salt => 'my_new_Salty_Salt_2')
        u1.salt.should == 'my_new_Salty_Salt_2'
      end

      it 'should use the generated salt, system key, and district key' do
        d = Factory(:district, :key => 'DisKye')
        
        u = Factory(:user, :district => d)
        u.password = 'motest'
        u.password_confirmation = 'motest'
        u.save!
        u.passwordhash.should == Digest::SHA1.hexdigest("#{System::HASH_KEY}motestDisKye#{u.salt}")
      end

    end
  end

  describe 'encrypted_password' do
    it 'should create a hash with a nil system key and district key and salt' do
      pending
      # User.encrypted_password('e')

      # set up user1 with password the old way
      # verify user1 password works

      # set new user2 up with new way
      # verify new password for user2 works

      # verify user1 password still works
    end

  end
  
  
  describe 'passwordhash' do
    it 'should be stored encrypted' do
      @user.passwordhash.should == User.encrypted_password('oneschool', @user.salt, nil, nil)
    end
  end
  
  describe 'password=' do
    it 'should change the password hash when not blank' do
      u=User.new(:password=>"DOG")
      u.passwordhash.should_not be_blank
      p=u.passwordhash
      u.password=""
      u.passwordhash.should == p
    end
  end

  it 'should include FullName' do
    User.included_modules.should include(FullName)
  end

  it 'should have a middle_name' do
    Factory(:user, :middle_name => 'Edward').middle_name.should == 'Edward'
  end

  describe 'full_name' do
    u=User.new(:first_name=>"0First.", :last_name=>"noschools")
    u.fullname.should == ("0First. noschools")
    u.to_s.should == ("0First. noschools")
  end
  
  describe 'authorized_groups_for_school' do
    it 'should return school groups when user is a member of all groups in school' do
      u=User.new
      s=mock_school(:groups=>"THEE GROUPS HERE")

      u.stub_association!(:special_user_groups,:all_students_in_school? =>true )
      u.authorized_groups_for_school(s).should == s.groups
    end

    it 'should call groups.by_school when user is not a member of all groups in school' do
      u=User.new
      s=mock_school
      u.stub_association!(:special_user_groups,:all_students_in_school? =>false )
      u.stub_association!(:groups,:by_school => "GROUPS BY SCHOOL" )
      u.authorized_groups_for_school(s).should ==  "GROUPS BY SCHOOL"


    end
  end
  
  describe 'filtered_groups_by_school' do
    it 'should return all authorized_groups for school if prompt is blank' do
      @user.should_receive(:authorized_groups_for_school).with('s1').any_number_of_times.and_return(['group 2', 'group 1'])
      g1=Group.new
      Group.should_receive(:new).with(:id=>"*", :title =>"Filter by Group").any_number_of_times.and_return(g1)
      
      @user.filtered_groups_by_school('s1').should == [g1,'group 2', 'group 1']
    end

    it 'should return one authorized group with prompt depending on special user groups' do
      g1=Group.new
      Group.should_receive(:new).with(:id=>"*", :title =>"Filter by Group").any_number_of_times.and_return(g1)
     
      @user.stub_association!(:special_user_groups,'all_students_in_school?'=>false)
      @user.should_receive(:authorized_groups_for_school).with('s1').any_number_of_times.and_return(['group 1'])
      @user.filtered_groups_by_school('s1').should == ['group 1']
      @user.stub_association!(:special_user_groups,'all_students_in_school?'=>true)
      @user.filtered_groups_by_school('s1').should == [g1,'group 1']
    end

    it 'should filter groups if prompt' do
      s=Factory(:school)
      @user.filtered_groups_by_school(s,:grade=>'E',:user=>5 ).should == []
    end
  end
 
  describe 'filtered_members_by_school' do
    before do
      @g1=User.new

    end
    
     it 'should return all authorized_members if prompt is blank' do
        User.should_receive(:new).with(:id=>"*", :first_name =>"All", :last_name => "Staff").any_number_of_times.and_return(@g1)
        @user.stub_association!(:authorized_groups_for_school, :members => ["Zebra", "Elephant", "Tiger"])
        @user.filtered_members_by_school('s1').should == [@g1,'Elephant', 'Tiger', 'Zebra']
      end

    it 'should return one authorized group with prompt depending on special user groups' do
      User.should_receive(:new).with(:id=>"*", :first_name =>"All", :last_name => "Staff").any_number_of_times.and_return(@g1)
      @user.stub_association!(:authorized_groups_for_school, :members => ["Zebra"])
      @user.stub_association!(:special_user_groups,'all_students_in_school?'=>false)
      @user.filtered_members_by_school('s1').should == ['Zebra']
      @user.stub_association!(:special_user_groups,'all_students_in_school?'=>true)
      @user.filtered_members_by_school('s1').should == [@g1,'Zebra']
     
    end

    it 'should filter groups if prompt' do
      s=Factory(:school)
      @user.filtered_members_by_school(s,:grade=>'E').should == []
    end
  end

  describe 'authorized_ for' do 
    it 'should return false if unknown action_group_type' do
      User.new().authorized_for?('','unknown_group_not_write_or_read').should == false
    end

    it 'should call check for read rights when group is read' do
      Role.should_receive(:has_controller_and_action_group?).with('test_controller','read').and_return(true)
      User.new.authorized_for?('test_controller','read').should == true
    end

    it 'should call check for write rights when group is write' do
      Role.should_receive(:has_controller_and_action_group?).with('test_controller','write').and_return(true)
      User.new.authorized_for?('test_controller','write').should == true
    end
  end

  describe "principal?" do
    it 'should return true if principal of a group or special user group and false if not' do
      u=@user
      u.principal?.should == false
      u.user_group_assignments.create!(:is_principal=>true, :group_id=>11)
      u.principal?.should == true
      u.user_group_assignments.clear
      u.principal?.should == false
      u.special_user_groups.create!(:is_principal => true ,:grouptype=>2, :district_id => 11)
      u.principal?.should == true
    end
  end

  describe 'grouped_principal_overrides' do
    it 'should group requests, responses and pending' do
      @user.grouped_principal_overrides.should == {:user_requests => []}
      req='New Override Request'
      @user.stub!(:principal_override_requests=> [req])
      @user.grouped_principal_overrides.should == {:user_requests => [req]}

      @user.stub!(:principal? => true)
      @user.stub!(:principal_override_responses => ["Principal Override Response"])
      PrincipalOverride.should_receive(:pending_for_principal).with(@user).and_return(["Pending For Principal"])
      @user.grouped_principal_overrides.should == {:user_requests => [req], :principal_responses => ["Principal Override Response"], 
          :pending_requests => ["Pending For Principal"]}
    end
  end

  describe 'authorized_schools' do
    it 'should return blank for user with no schools' do
      @user.authorized_schools.should be_blank
      @user.authorized_schools('zzz').should be_blank
    end

    it 'should return all schools for user with access to all schools' do
      s1=Factory(:school, :district => @user.district)
      s2=Factory(:school, :district => @user.district)
      s3=Factory(:school, :district => @user.district)
      s4=Factory(:school)
      @user.special_user_groups.create!(:grouptype => SpecialUserGroup::ALL_STUDENTS_IN_DISTRICT, :district => @user.district)
      @user.authorized_schools.should == [s1,s2,s3]
      @user.authorized_schools(s1.id).should == [s1]
      @user.authorized_schools('qqq').should == []
    end

    it 'should return s1 and s3 for user with access to s1 and special access tp s3' do
      s1=Factory(:school, :district => @user.district)
      s2=Factory(:school, :district => @user.district)
      s3=Factory(:school, :district => @user.district)
      
      @user.schools << s1
      @user.special_user_groups.create!(:grouptype => SpecialUserGroup::ALL_STUDENTS_IN_SCHOOL, :school => s3)
      @user.authorized_schools.should == [s1,s3]
      @user.authorized_schools(s1.id).should == [s1]
      @user.authorized_schools(s2.id).should == []
    end
  end
end
