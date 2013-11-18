class MiniVenmo::Payment < ActiveRecord::Base
  class RecordInvalid < StandardError; end

  belongs_to :actor,  :class_name => MiniVenmo::User
  belongs_to :target, :class_name => MiniVenmo::User

  validates :amount, :numericality => { :greater_than => BigDecimal.new('0') }
  validates :actor,  :presence => true
  validates :target, :presence => true
  validate  :actor_and_target_have_cards

  def self.pay(actor, target, amount, note = '')
    amount = amount[1..-1] # strip off dollar sign
    actor  = MiniVenmo::User.find_by_name(actor)
    target = MiniVenmo::User.find_by_name(target)

    payment = new(:actor   => actor,
                  :target  => target,
                  :amount  => BigDecimal.new(amount),
                  :note    => note)

    if payment.save
      target.update_attribute(:balance, target.balance + BigDecimal.new(amount))
      puts "#{actor} paid #{target} $#{amount.to_s} in concept - #{note}"
    else
      puts "Could not create payment - #{payment.errors.full_messages.join(', ')}"
      raise MiniVenmo::Payment::RecordInvalid
    end
  end

  private

  def actor_and_target_have_cards
    begin
      errors.add(:actor, "#{actor} needs a card")    unless actor.card.present?
      errors.add(:target, "#{target} needs a card") unless target.card.present?
    rescue
      errors.add(:payment, "needs a valid actor and target")
    end
  end
end
