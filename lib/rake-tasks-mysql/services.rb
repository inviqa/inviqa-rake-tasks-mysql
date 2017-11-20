require 'yaml'
require 'rake-tasks-docker'

module RakeTasksDockerSync
  class Services < RakeTasksDocker::Services
    def initialize(name)
      unless name
        hem_config = {}
        %w[tools/hem/config.yaml tools/hobo/config.yaml].each do |file|
          hem_config = YAML.load_file(file) if !hem_config && File.exist?(file)
        end
        name = hem_config[:name]
      end

      @services = ["#{name}-sync"]
    end

    def refresh
      containers = `docker ps -q | grep -E '(#{@services.map { |service| Regexp.escape(service) }.join('|')})'`.split("\n")
      @inspections = []
      containers.each do |container_ref|
        @inspections << JSON.parse(`docker inspect #{container_ref}`).first
      end
    end

    def up
      system 'mysql', 'start'
    end

    def stop
      system 'mysql', 'stop', '-v'
    end

    def down
      system 'mysql', 'clean'
    end

    def build
      # no-op
    end

    def exec(user, command)
      @services.each do |service|
        system 'docker', 'exec', '--user', user, service, command
      end
    end
  end
end
