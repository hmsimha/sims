require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe ApplicationController do
  def flash
    @flash ||= {}
  end

  def mock_object(*args)
    @mo ||= Object.new
    @mo.stub!(*args||{})
  end

  describe 'mock_request' do
    before do
      @req=mock(:subdomain=>'')
      controller.stub!(:request).and_return(@req)
      @req.stub!(:url=>"gopher://www.example.com/")
      @req.stub!(:domain=>"www.example.com")
      controller.stub!(:params).and_return(flash)
    end

    describe 'authorize' do

      it 'should return true if authorized' do
        user=mock_user
        controller.should_receive(:current_user).and_return(user)
        user.should_receive(:authorized_for?).with('application').and_return(true)
        controller.send(:authorize).should == true

      end

      it 'should redirect and set a flash message if not authorized' do
        user=mock_user
        controller.should_receive(:current_user).and_return(user)
        user.should_receive(:authorized_for?).with('application').and_return(false)
        controller.should_receive(:not_authorized_url).and_return 'root_url'
        controller.should_receive(:redirect_to).with('root_url')
        controller.should_receive(:flash).and_return(flash)
        controller.send(:authorize).should == false
        flash[:notice].should == "You are not authorized to access that page"


      end
    end

    describe 'require_school' do

      it 'should redirect and set a flash message if there is no school when html' do
        controller.should_receive(:current_school).and_return("")
        controller.should_receive(:schools_url).and_return("schools_url")
        controller.should_receive(:redirect_to).with('schools_url')
        controller.should_receive(:flash).and_return(flash)
        @req.should_receive(:xhr?).and_return(false)

        controller.send(:require_current_school).should == false
        flash[:notice].should == "Please reselect the school"

      end

      it 'should put up a message when xhr and there is no school' do

        controller.should_receive(:current_school).and_return("")
        @req.should_receive(:xhr?).and_return(true)
        page=mock_object({})
        page.should_receive(:[]).with(:flash_notice).and_return(page)
        page.should_receive(:insert).with("<br />Please reselect the school.")
        controller.should_receive(:render).and_yield(page)
        controller.send(:require_current_school).should == false

      end

      it 'should return true if there is a school' do
        controller.should_receive(:current_school).and_return("CURRENT")
        controller.send(:require_current_school).should == true
      end

    end

    it 'has selected_student session helkpers' do
      controller.stub!(:session=>{:selected_students=>[1,2,3]})
      controller.send(:selected_student_ids).should == [1,2,3]
      controller.send('multiple_selected_students?').should == true

      controller.stub!(:session=>{:selected_students=>[1]})
      controller.send('multiple_selected_students?').should == false
    end

  end

  describe 'check_student' do
    it 'should have specs'
  end

  describe "selected_student_ids" do
    before do
      @session = {:session_id => 'tree'}
      controller.stub!(:session => @session, :current_user => mock_user)
    end
    it 'should work normally with under <50 ids' do
      controller.send :selected_student_ids=, [1,2,3]
      controller.send(:selected_student_ids).should == [1,2,3]
    end

    it 'should cache when there are more than 50 ids' do
      values = (1...1000).to_a
      controller.send :selected_student_ids=, values
      @session[:selected_students].should == "memcache"
      if ENV['TRAVIS']
        puts "SKIPPING because memcache is not working on travis-ci"
      else
        controller.send(:selected_student_ids).should == values
        controller.instance_variable_set "@memcache_student_ids", nil
        @session[:session_id] = "bush"
        controller.send(:selected_student_ids).should_not == values  #if session_id changes
        controller.instance_variable_set "@memcache_student_ids", nil
        @session[:session_id] = "tree"
        controller.stub!(:current_user => User.new)
        controller.send(:selected_student_ids).should_not == values  #if user changes
      end
    end

  end


  describe 'root_url' do
    before do
      @c = ApplicationController.new
      @req = ActionDispatch::TestRequest.new
      @c.request =@req
      #@c.set_current_view_context
    end

    describe 'with_subdomain' do
      before do
        @c.stub!(:current_district =>mock(:abbrev => 'rspec'))
      end
      it '127.0.0.1:3000' do
        @req.env["HTTP_HOST"] = "127.0.0.1"
        @req.stub(:port => "3000")
        @c.send(:root_url_with_subdomain).should == "http://127.0.0.1:3000/"
      end
      it 'www.example.com:3000' do
        @req.env["HTTP_HOST"] = "www.example.com"
        @req.stub(:port => "3000")
        @c.send(:root_url_with_subdomain).should == "http://rspec.example.com:3000/"
      end
      it 'www.example.com' do
        @req.env["HTTP_HOST"] = "www.example.com"
        @req.stub(:port => "80")
        @c.send(:root_url_with_subdomain).should == "http://rspec.example.com:80/"
      end
      it 'example.com' do
        @req.env["HTTP_HOST"] = "www.example.com"
        @req.stub(:port => "80")
        @c.send(:root_url_with_subdomain).should == "http://rspec.example.com:80/"
      end

      it 'https://www.example.com' do
        @req.env["HTTP_HOST"] = "www.example.com"
        @req.env["HTTPS"] = "on"
        @req.stub(:port => "443")
        @c.send(:root_url_with_subdomain).should == "https://rspec.example.com:443/"
      end
      it 'training.example.com' do
        @req.env["HTTP_HOST"] = "training.example.com"
        @req.stub(:port => "80")
        @c.send(:root_url_with_subdomain).should == "http://rspec.example.com:80/"
      end
      it 'https://training.example.com' do
        @req.env["HTTP_HOST"] = "training.example.com"
        @req.stub(:port => "80")
        @c.send(:root_url_with_subdomain).should == "http://rspec.example.com:80/"
      end
    end
    describe 'without_subdomain' do
      it 'www.example.com:3000' do
        @req.env["HTTP_HOST"] = "www.example.com"
        @req.stub(:port => "3000")
        @c.send(:root_url_without_subdomain).should == "http://www.example.com:3000/"
      end
      it 'www.example.com' do
        @req.env["HTTP_HOST"] = "www.example.com"
        @req.stub(:port => "80")
        @c.send(:root_url_without_subdomain).should == "http://www.example.com:80/"
      end
      it 'example.com' do
        @req.env["HTTP_HOST"] = "www.example.com"
        @req.stub(:port => "80")
        @c.send(:root_url_without_subdomain).should == "http://www.example.com:80/"
      end

      it '127.0.0.1:3000' do
        @req.env["HTTP_HOST"] = "127.0.0.1"
        @req.stub(:port => "80")
        @c.send(:root_url_without_subdomain).should == "http://127.0.0.1:80/"
      end
      it 'https://www.example.com' do
        @req.env["HTTP_HOST"] = "www.example.com"
        @req.env["HTTPS"] = "on"
        @req.stub(:port => "443")
        @c.send(:root_url_without_subdomain).should == "https://www.example.com:443/"
      end
      it 'training.example.com' do
        @req.env["HTTP_HOST"] = "training.example.com"
        @req.stub(:port => "80")
        @c.send(:root_url_without_subdomain).should == "http://www.example.com:80/"
      end
      it 'https://training.example.com' do
        @req.env["HTTP_HOST"] = "training.example.com"
        @req.stub(:port => "80")
        @c.send(:root_url_without_subdomain).should == "http://www.example.com:80/"
      end
      describe 'sims-open' do
        before do
        @old_domain_length = ::SIMS_DOMAIN_LENGTH
        Object.send(:remove_const, "SIMS_DOMAIN_LENGTH")
        ::SIMS_DOMAIN_LENGTH=2
        end

        after do
          Object.send(:remove_const, "SIMS_DOMAIN_LENGTH")
          ::SIMS_DOMAIN_LENGTH= @old_domain_length
        end

        it 'sims-open.vegantech.com' do
          @req.env["HTTP_HOST"] = "sims-open.vegantech.com"
          @req.stub(:port => "80")
          @c.send(:root_url_without_subdomain).should == "http://www.sims-open.vegantech.com:80/"
        end
        it 'training.sims-open.vegantech.com' do
          @req.env["HTTP_HOST"] = "training.sims-open.vegantech.com"
          @req.stub(:port => "80")
          @c.send(:root_url_without_subdomain).should == "http://www.sims-open.vegantech.com:80/"
        end
      end

    end
  end

  describe 'check_domain' do
    before do
      @c = ApplicationController.new
      @req = ActionDispatch::TestRequest.new
      @c.request =@req
      #@c.set_current_view_context
    end

    it 'should return true for devise controller' do
      @c.should_receive(:devise_controller?).and_return true
      @c.send(:check_domain).should be_true
    end

    it 'should pass through if there is no current district' do
      @c.should_receive(:current_district).and_return nil
      @c.send(:check_domain).should be_nil
    end

    it 'should pass through if the current district matches the subdomain' do
      @c.stub!(:current_district=> mock_district(:abbrev => "test"))
      @c.should_receive(:current_subdomain).and_return "test"
      @c.send(:check_domain).should be_nil
    end

    it 'should sign out if the subdomain matches another district' do
      @c.stub!(:current_district=> mock_district(:abbrev => "test"))
      @c.stub!(:current_subdomain => "other")
      Factory(:district, :abbrev => "other")
      @c.should_receive(:sign_out_and_redirect)
      @c.send(:check_domain).should be_false
    end

    it 'should pass theough if the subdomain matches no district' do
      @c.stub!(:current_district => mock_district(:abbrev => "test"))
      @c.stub!(:current_subdomain => "www")
      @c.send(:check_domain).should be_nil
    end
  end



end

