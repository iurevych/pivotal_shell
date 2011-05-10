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
      @story = PivotalShell::Configuration.project.stories.find(arguments.first) unless arguments.empty?

    end

    def execute
      if `git diff --staged`.empty?
        puts "No changed staged to commit."
        exit 1
      end
      stories = PivotalShell::Configuration.project.stories.all( 
        :owner => PivotalShell::Configuration.me,
        :state => %w(started finished delivered),
        :limit => 30
      )

      unless @story
        unless stories.empty?
          stories.each_with_index do |story, index|
            puts "[#{index + 1}] #{story.name}"
          end
          puts ""
          index = Readline.readline("Index: ", true).to_i
          @story = stories[index - 1]

        end
      end
      if @story
        message = <<-MSG
#{("[\##{@story.id}]").rjust 12} 
#{@message}\n\n Feature:#{@story.name.strip}
MSG
        puts `git commit -m "#{message}"`
      else
        puts "Story not found"
      end
    end
  end
end
