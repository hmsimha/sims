require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReportsHelper do

  describe 'subreport_selected' do
    describe 'passed "1"' do
      it 'should execute passed in code block' do
        m = mock
        m.should_receive(:message).and_return(false)
        helper.subreport_selected('1') {m.message}
      end
    end

    describe 'not passed "1"' do
      it 'should not execute code block' do
        m = 'mock'
        m.should_not_receive(:message)
        helper.subreport_selected('0') {m.message}
      end
    end
  end
end
