require 'spec_helper'

describe MiniVenmo::Card do

  describe '.associate' do
    context 'when adding a valid card' do
      before(:each) do
        MiniVenmo::User.add('foos')
        MiniVenmo::Card.add('foos', '4111111111111111')
      end

      it { expect(MiniVenmo::Card.count).to eql 1 }
      it { expect(MiniVenmo::Card.decrypt(MiniVenmo::Card.first.number)).to eql '4111111111111111' }
      it { expect(MiniVenmo::Card.first.user.name).to eql 'foos' }
      it { expect(MiniVenmo::Card.decrypt(MiniVenmo::User.find_by_name('foos').card.number)).to eql '4111111111111111' }
    end

    context 'when adding an invalid card' do
      before(:each) do
        MiniVenmo::User.add('foos')
      end

      it 'validates card is associated to an user' do
        expect { MiniVenmo::Card.add('foos', '4111111111111111') }.not_to raise_error
      end
      it 'validates the given user exists' do
        expect { MiniVenmo::Card.add('nonexistentuser', Luhnacy.generate(10))
               }.to raise_error MiniVenmo::Card::RecordInvalid
      end

      it 'validates card number is luhn compliant' do
        invalid_card = '1234567890123456'
        expect { MiniVenmo::Card.add('foos', invalid_card)
               }.to raise_error MiniVenmo::Card::RecordInvalid
      end

      it 'validates card uniqueness' do
        MiniVenmo::User.add('bars')
        users = %w(foos bars)
        expect { users.each { |user| MiniVenmo::Card.add(user, '4111111111111111') }
               }.to raise_error MiniVenmo::Card::RecordInvalid
      end

      it 'validates card length' do
        expect { MiniVenmo::Card.add('foos', Luhnacy.generate(20))
               }.to raise_error MiniVenmo::Card::RecordInvalid
      end

      it "does not allow users to have two cards" do
        card_numbers = [Luhnacy.generate(10), Luhnacy.generate(10)]
        expect { card_numbers.each { |number| MiniVenmo::Card.add('foos', number) }
               }.to raise_error MiniVenmo::Card::RecordInvalid
      end
    end
  end
end
