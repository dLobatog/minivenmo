require 'luhnacy'

class MiniVenmo::Card < ActiveRecord::Base
  class RecordInvalid < StandardError; end

  belongs_to :user

  validates :number,                           :presence => true
  validates :user  ,      :uniqueness => true, :presence => true
  validates :number_hash, :uniqueness => true, :presence => true
  validate  :luhn_compliant
  validate  :card_length

  class << self
    def add(user_name, card_number)
      new_card = new(:number => card_number)
      unless (new_card.user = MiniVenmo::User.find_by_name(user_name)).present?
        puts "Cannot add card to user #{user_name}: user does not exist"
        raise MiniVenmo::Card::RecordInvalid
      end

      new_card.number_hash = Base64.encode64(Digest::SHA256.digest(card_number))
      new_card.number      = encrypt(card_number)

      if new_card.save
        puts "User #{new_card.user} associated with card #{decrypt(new_card.number)} successfully"
      else
        puts "Could not create card #{card_number} - #{new_card.errors.full_messages.join(', ')}"
        raise MiniVenmo::Card::RecordInvalid
      end
    end

    def encryptor
      ActiveSupport::MessageEncryptor.new(MiniVenmo::ENCRYPTION_KEY)
    end

    def encrypt(number)
      encryptor.encrypt_and_sign(number)
    end

    def decrypt(number)
      encryptor.decrypt_and_verify(number)
    end
  end

  private

  def luhn_compliant
    decrypted_card = MiniVenmo::Card.decrypt(number)
    errors.add(:number, "#{decrypted_card} is not Luhn compliant") unless Luhnacy.valid?(decrypted_card)
  end

  def card_length
    decrypted_card = MiniVenmo::Card.decrypt(number)
    errors.add(:number, "#{decrypted_card} is too long (19 characters max.)") unless decrypted_card.length <= 19
  end
end
