require 'fileutils'
require 'git'

require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::LinearHistory do
    it 'should be a plugin' do
      expect(Danger::LinearHistory.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.linear_history
      end

      context 'with linear history' do
        before(:all) do
          repo = File.expand_path('../fixtures/linear', __FILE__)
          @dir = Dir.mktmpdir
          FileUtils.cp_r(repo, @dir + '/.git')
          @git = Git.open(@dir)
        end

        after(:all) do
          FileUtils.rm_rf(@dir)
        end

        it 'does nothing' do
          allow_any_instance_of(Danger::LinearHistory).to \
            receive(:commits).and_return @git.log

          @my_plugin.validate!

          expect(@dangerfile.status_report[:warnings]).to eq([])
          expect(@dangerfile.status_report[:errors]).to eq([])
        end
      end

      context 'with nonlinear history' do
        before(:all) do
          repo = File.expand_path('../fixtures/nonlinear', __FILE__)
          @dir = Dir.mktmpdir
          FileUtils.cp_r(repo, @dir + '/.git')
          @git = Git.open(@dir)
        end

        after(:all) do
          FileUtils.rm_rf(@dir)
        end

        context 'soft_fail is false' do
          it 'errors' do
            allow_any_instance_of(Danger::LinearHistory).to \
              receive(:commits).and_return @git.log

            @my_plugin.validate!(soft_fail: false)

            message = 'Please rebase to get rid of the merge commits in this PR'
            expect(@dangerfile.status_report[:warnings]).to eq([])
            expect(@dangerfile.status_report[:errors]).to eq([message])
          end
        end

        context 'soft_fail is true' do
          it 'warns' do
            allow_any_instance_of(Danger::LinearHistory).to \
              receive(:commits).and_return @git.log

            @my_plugin.validate!(soft_fail: true)

            message = 'Please rebase to get rid of the merge commits in this PR'
            expect(@dangerfile.status_report[:warnings]).to eq([message])
            expect(@dangerfile.status_report[:errors]).to eq([])
          end
        end
      end
    end
  end
end
