require 'spec_helper'

describe MiniVenmo::Payment do

  describe '.payment' do
    context 'when making a valid payment' do
      before(:each) do
        MiniVenmo::User.add('payer')
        MiniVenmo::User.add('payee')
        MiniVenmo::Card.add('payer', Luhnacy.generate(10))
        MiniVenmo::Card.add('payee', Luhnacy.generate(10))
        MiniVenmo::Payment.pay('payer', 'payee', '$3.2', 'testpayment')
      end

      it { expect(MiniVenmo::Payment.count).to eql 1 }
      it { expect(MiniVenmo::Payment.first.actor.name).to  eql 'payer' }
      it { expect(MiniVenmo::Payment.first.target.name).to eql 'payee' }
      it { expect(MiniVenmo::Payment.first.amount).to      eql 3.2 }
      it { expect(MiniVenmo::Payment.first.note).to        eql 'testpayment' }

      it { expect(MiniVenmo::User.find_by_name('payer').payments.count).to eql 1 }
      it { expect(MiniVenmo::User.find_by_name('payee').payments.count).to eql 1 }

      it { expect(MiniVenmo::User.find_by_name('payee').balance).to eql BigDecimal.new('3.2') }
      it 'charges payer' do
        charges = MiniVenmo::User.find_by_name('payer').charges.map(&:amount).reduce(:+)
        charges.should == BigDecimal.new('3.2')
      end
    end

    context 'when making an invalid payment' do
      it 'validates actor and target existence' do
        payment = Proc.new { MiniVenmo::Payment.pay('payer', 'payee', '$3.2', 'testpayment') }
        expect(payment).to raise_error MiniVenmo::Payment::RecordInvalid
      end

      it 'validates actor and target have cards' do
        MiniVenmo::User.add('payer')
        MiniVenmo::User.add('payee')
        payment = Proc.new { MiniVenmo::Payment.pay('payer', 'payee', '$3.2', 'testpayment') }
        expect(payment).to raise_error MiniVenmo::Payment::RecordInvalid
      end

      it 'empty payments do not work' do
        MiniVenmo::User.add('payer')
        MiniVenmo::User.add('payee')
        MiniVenmo::Card.add('payer', Luhnacy.generate(10))
        MiniVenmo::Card.add('payee', Luhnacy.generate(10))
        payment = Proc.new { MiniVenmo::Payment.pay('payer', 'payee', '$0.0', 'testpayment') }
        expect(payment).to raise_error MiniVenmo::Payment::RecordInvalid
      end
    end
  end

end
