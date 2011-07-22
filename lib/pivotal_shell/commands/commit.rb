require "readline"

module PivotalShell::Commands
  class PivotalShell::Commands::Commit < PivotalShell::Command
    def initialize(arguments)

      opts = OptionParser.new do |opts|
        opts.banner = "Do git commit with information from pivotal story"
        opts.on("-m [MESSAGE]", "Add addional MESSAGE to comit") do |message|
          @message = message
        end
      end
      opts.parse!

      unless arguments.empty?
        @stories = arguments.map do |argument|
          PivotalShell::Configuration.project.stories.find(argument) 
        end
      end

    end

    def execute
      if `git diff --staged`.empty?
        puts "No changes staged to commit."
        exit 1
      end
      all_stories = PivotalShell::Configuration.project.stories.all( 
        :owner => PivotalShell::Configuration.me,
        :state => %w(started finished delivered),
        :limit => 30
      )

      unless @stories
        unless all_stories.empty?
          all_stories.each_with_index do |story, index|
            puts "[#{index + 1}] #{story.name}"
          end
          puts ""
          @stories  = Readline.readline("Indexes(csv): ", true).split(/\s*,\s*/).reject do |string|
            string == ""
          end.map do |string|
            index = string.to_i
            all_stories[index - 1] || (return puts("Story index #{index} not found."))
          end

        end
      end
      message = ("[#{@stories.map { |s| "\##{s.id}"}.join(", ")}]").rjust 12
      message += @message.to_s + "\n\n"
      message += @stories.map {|s| "Feature: " + s.name.strip}.join("\n\n")
      puts `git commit -m "#{message}"`
    end
  end
end
