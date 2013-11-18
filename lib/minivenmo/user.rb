class MiniVenmo::Payment < ActiveRecord::Base; end # avoids circular dependency

class MiniVenmo::User < ActiveRecord::Base
  class RecordInvalid < StandardError; end

  has_one  :card,     :dependent => :destroy
  has_many :charges,  :class_name => MiniVenmo::Payment, :foreign_key => 'actor_id'
  has_many :earnings, :class_name => MiniVenmo::Payment, :foreign_key => 'target_id'

  def payments
    charges + earnings
  end

  validates :name, :uniqueness => true,
                   :length     => { :in   => 4..15 },
                   :format     => { :with => /\A[a-zA-Z0-9\-_]+\z/,
                                    :message => "Alphanumeric, - and _ allowed" }
  validates :balance, :presence => true

  def self.add(name)
    user = new(:name => name, :balance => 0)

    if user.save
      puts "User #{name} created successfully"
    else
      puts "Could not create user #{name} - #{user.errors.full_messages.join(', ')}"
      raise MiniVenmo::User::RecordInvalid
    end

    user
  end

  def feed
    puts '---- CHARGES ---- '
    charges.each do |charge|
      puts "You paid #{charge.target} $#{charge.amount} for concept: #{charge.note} "
    end
    puts
    puts '---- EARNINGS ---- '
    earnings.each do |earning|
      puts "#{earning.actor} paid you $#{earning.amount} for concept: #{earning.note} "
    end
  end

  def to_s
    name
  end
end
