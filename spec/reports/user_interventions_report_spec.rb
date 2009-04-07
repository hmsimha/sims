require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserInterventionsReport do
  describe 'render_text' do
    it 'should generate correct text output' do
      now = Date.new(2008, 12, 12).to_time
      Time.stub!(:now => now)

      ip = Factory(:intervention_participant, :role => 1)

      report_body = UserInterventionsReport.render_text(:user => ip.user) #, :start_date => start_date, :end_date => end_date, :school => school)

      report_body.should == <<EOS
Report Generated at December 12, 2008 00:00

First Last:

+---------------------------------------------------------------------------------------------------------+
|    Role     |     Title / Status     | Start Date |     Frequency     | Active | Time Length | End Date |
+---------------------------------------------------------------------------------------------------------+
| Participant | #{ip.intervention.title.ljust(22)} |            | 1 time Freq Title | true   | 1 Default   |          |
+---------------------------------------------------------------------------------------------------------+

EOS
    end
  end
end