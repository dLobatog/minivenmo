require 'spec_helper'

describe MiniVenmo::User do
  describe '.add' do
    context 'when adding a valid user' do
      before(:each) { MiniVenmo::User.add('foos') }
      it { expect(MiniVenmo::User.count).to eql 1 }
      it { expect(MiniVenmo::User.first.name).to eql 'foos' }
      it { expect(MiniVenmo::User.first.balance).to eql 0 }
    end

    context 'when adding an invalid user' do
      it 'validates uniqueness' do
        expect { 2.times { MiniVenmo::User.add('foos') }
               }.to raise_error MiniVenmo::User::RecordInvalid
      end

      it "validates alphanumeric plus underscores and dashes" do
        # Whitespace is not allowed
        expect { MiniVenmo::User.add('Ffoo3829s _-') }.to raise_error MiniVenmo::User::RecordInvalid

        # Works without whitespace
        expect { MiniVenmo::User.add('Ffoo3829s_-') }.to change { MiniVenmo::User.count }.by(1)
      end

      it "validates length no shorter than 4 no longer than 15" do
        expect { MiniVenmo::User.add('o' * 3)  }.to raise_error MiniVenmo::User::RecordInvalid
        expect { MiniVenmo::User.add('o' * 16) }.to raise_error MiniVenmo::User::RecordInvalid
      end
    end
  end

  describe '#balance' do
    context 'when starting the account' do
      before(:each) { MiniVenmo::User.add('foos') }
      subject { MiniVenmo::User.find_by_name('foos') }

      its(:balance) { should == 0 }
    end
  end
end
