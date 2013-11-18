require 'optparse'
require 'readline'

class MiniVenmo::Bin
  def initialize(args)
    @args = args
  end

  def run
    help = <<-EOHELP
    MiniVenmo

    Run minivenmo [COMMAND] --help for more information about an specific command.

    Basic Command Line Usage:
      minivenmo user
                add
                pay
                feed
                balance
                shell

      Options:
    EOHELP

    global = OptionParser.new do |opts|
      opts.banner = help

      opts.on('-v', '--version', 'Displays current version') do
        puts 'MiniVenmo ' + MiniVenmo::VERSION
        return 0
      end

      opts.on('-f', '--file', 'Takes input commands from file') do
        filepath = @args.first

        if filepath
          File.read(filepath).lines.each do |line|
            puts line.split.inspect
            MiniVenmo::Bin.new(line.split).run
          end
        else
          puts '--file needs an input file with minivenmo commands'
          return 1
        end
      end
    end

    subcommands = {
      'user' => OptionParser.new do |opts|
        opts.banner = "Usage: user [NAME] - adds new user to minivenmo"
        opts.on("default", "add user") do |v|
          name = @args.first
          begin
            MiniVenmo::User.add(name)
            return 0
          rescue MiniVenmo::User::RecordInvalid
            return 1
          end
        end
      end,

      'add' => OptionParser.new do |opts|
        opts.banner = 'Usage: add [NAME] [CARD]- adds [CARD] to [USER]'
        opts.on('default', 'add card to user') do |v|
          name, card = @args.first, @args.last
          begin
            MiniVenmo::Card.add(name, card)
            return 0
          rescue MiniVenmo::Card::RecordInvalid
            return 1
          end
        end
      end,

      'pay' => OptionParser.new do |opts|
        opts.banner = "Usage: pay [ACTOR] [TARGET] [AMOUNT] [NOTE] - make a payment of [AMOUNT] from [ACTOR]'s credit card to [TARGET] leaving a payment concept [NOTE]"
        opts.on('default', 'make payment') do |v|
          actor, target, amount = @args[0], @args[1], @args[2]
          note                  = @args[3..(@args.length - 1)].join(' ')
          begin
            MiniVenmo::Payment.pay(actor, target, amount, note)
            return 0
          rescue MiniVenmo::Payment::RecordInvalid
            return 1
          end
        end
      end,

      'feed' => OptionParser.new do |opts|
        opts.banner = "Usage: feed [NAME] - shows [NAME]'s payments feed'"
        opts.on('default', 'show feed') do |v|
          user = MiniVenmo::User.find_by_name(@args.first)
          if user.present?
            user.feed
            return 0
          else
            puts "Could not check feed: User #{@args.first} does not exist"
            return 1
          end
        end
      end,

      'balance' => OptionParser.new do |opts|
        opts.banner = "Usage: balance [NAME] - shows [NAME]'s balance"
        opts.on('default', 'show balance') do |v|
          user = MiniVenmo::User.find_by_name(@args.first)
          if user.present?
            puts "#{user}'s balance is #{user.balance}"
            return 0
          else
            puts "Could not check balance: User #{@args.first} does not exist"
            return 1
          end
        end
      end,

      'shell' => OptionParser.new do |opts|
        opts.banner = "Usage: shell - starts a minivenmo shell"
        opts.on('default', 'start shell') do |v|
          begin
            while line = Readline.readline('minivenmo> ', true)
              if subcommands.keys.include? (args = line.split).first
                MiniVenmo::Bin.new(line.split).run unless line.start_with? 'shell'
              else
                puts "Unknown command #{args.first}"
              end
            end
          rescue Interrupt => e
            puts
            puts 'Bye bye'
            return 0
          end
        end
      end
    }

    if @args[0].nil?
      puts "minivenmo: no command specified"
      puts "minivenmo: try 'minivenmo --help' for more information"
      return 1
    end

    begin
      global.parse!(@args)
      command = @args.shift
      subcommands[command].order! unless subcommands[command].nil?
    rescue OptionParser::InvalidOption
      puts "minivenmo: #{$!.message}"
      puts "minivenmo: try 'minivenmo --help' for more information"
      return 1
    end

    return 0
  end

end
