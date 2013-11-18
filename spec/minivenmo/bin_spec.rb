require 'spec_helper'
require 'optparse'

class CommandRun
  attr_accessor :stdout, :stderr, :exitstatus

  def initialize(args)
    out = StringIO.new
    err = StringIO.new

    $stdout = out
    $stderr = err

    @exitstatus = MiniVenmo::Bin.new(args).run

    @stdout = out.string.strip
    @stderr = err.string.strip

    $stdout = STDOUT
    $stderr = STDERR
  end
end

def create_user_through_console(name)
  MiniVenmo::Bin.new(['user', name]).run
end

describe MiniVenmo::Bin do
  context 'operations that do not require an user' do
    subject { CommandRun.new(args) }

    context 'when running without arguments' do
      let(:args)       { [] }
      its(:exitstatus) { should == 1 }
    end

    describe 'displays version' do
      let(:args) { ['--version'] }

      its(:exitstatus) { should == 0 }
      its(:stdout)     { should == "MiniVenmo #{MiniVenmo::VERSION}" }
    end

    describe 'creates user' do
      let(:args) { ['user', 'testuser'] }

      its(:exitstatus) { should == 0 }
      its(:stdout)     { should match /testuser created successfully/ }
    end

    context 'when checking feed of a non registered user' do
      user = 'nonexistentuser'
      let(:args) { ['feed', user] }

      its(:exitstatus) { should == 1 }
      its(:stdout)     { should match /Could not check feed: User #{user} does not exist/ }
    end

    context 'when checking balance of a non registered user' do
      user = 'testuser'
      let(:args) { ['balance', user] }

      its(:exitstatus) { should == 1 }
      its(:stdout)     { should match /Could not check balance: User #{user} does not exist/ }
    end
  end

  context 'operations that require an user' do
    before(:each) { silence_output; create_user_through_console('testuser') }

    describe 'associates an user with a card' do
      user, card = 'testuser', Luhnacy.generate(10)
      subject { CommandRun.new(['add', user, card]) }

      its(:exitstatus) { should == 0 }
      its(:stdout)     { should match /User #{user} associated with card #{card}/ }
    end

    describe 'displays users balance' do
      user = 'testuser'
      subject { CommandRun.new(['balance', user]) }

      its(:exitstatus) { should == 0 }
      its(:stdout)     { should match /#{user}'s balance is 0/ }
    end
  end

  context 'payments' do
    before(:each) do
      silence_output
      actor, target = 'testuser', 'receiver'
      amount, note  = '$10.50'  , 'test note'
      create_user_through_console(target)
      create_user_through_console(actor)
      MiniVenmo::Card.add(target, Luhnacy.generate(10))
      MiniVenmo::Card.add(actor, Luhnacy.generate(10))
    end

    describe 'makes a payment between two users' do
      subject { CommandRun.new(args) }

      let(:args) { %w(pay testuser receiver $10.50 test note) }

      its(:exitstatus) { should == 0 }
      its(:stdout) do
        should match /#{args[1]} paid #{args[2]} [$]#{args[3][1..-1].to_s} in concept - #{args[4..(args.length - 1)]}/
      end
    end

    describe 'displays users feed' do
      user = 'testuser'
      subject do
        CommandRun.new(%w(pay testuser receiver $10.50 test note));
        CommandRun.new(%w(pay receiver testuser $20.33 something else));
        CommandRun.new(['feed', user])
      end

      its(:exitstatus) { should == 0 }
      its(:stdout)     { should match /You paid receiver [$]10.5/ }
      its(:stdout)     { should match /receiver paid you [$]20.33 for concept: some/ }
    end
  end
end

