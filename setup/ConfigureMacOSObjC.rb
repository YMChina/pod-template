module Pod

  class ConfigureMacOSObjC
    attr_reader :configurator

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
    end

    def perform
      keep_demo = configurator.ask_with_answers("Would you like to include a demo application with your library", ["Yes", "No"]).to_sym

      framework = configurator.ask_with_answers("Which testing frameworks will you use", ["Quick", "None"]).to_sym
      case framework
        when :quick
          configurator.add_pod_to_podfile "Quick', '~> 2.2.0"
          configurator.add_pod_to_podfile "Nimble', '~> 8.0.7"
          configurator.set_test_framework "quick", "m", "macos-objc"

        when :none
          configurator.set_test_framework "xctest", "m", "macos-objc"
      end

      Pod::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "templates/macos-objc/Example/PROJECT.xcodeproj",
        :platform => :osx,
        :remove_demo_project => (keep_demo == :no),
        :prefix => ""
      }).run

      `mv ./templates/macos-objc/* ./`

      # There has to be a single file in the Classes dir
      # or a framework won't be created
      `touch Pod/Classes/ReplaceMe.m`

      `mv ./NAME-osx.podspec ./NAME.podspec`
    end
  end

end
