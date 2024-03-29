module ControlGroups
  class << self

    def rules_struct_init(node)
      if(node[:control_groups][:rules].nil? || node[:control_groups][:rules][:pid] != Process.pid)
        node[:control_groups][:rules] = {
          :active => {},
          :pid => Process.pid
        }
      end
    end

    def config_struct_init(node)
      if(node[:control_groups][:config].nil? || node[:control_groups][:config][:pid] != Process.pid)
        node[:control_groups][:config] = {
          :structure => {},
          :pid => Process.pid,
          :mounts => node[:control_groups][:mounts].to_hash
        }
      end
    end

    def build_rules(hash)
      output = ["# This file created by Chef!"]
      unless(hash.nil? || hash.empty?)
        hash.to_hash.each_pair do |user, args|
          output << "#{user}\t#{Array(args[:controllers]).join(',')}\t#{args[:destination]}"
        end
      end
      output.join("\n") << "\n"
    end

    def build_config(hash)
      output = ["# This file created by Chef!"]
      builder(hash[:structure], output, 0, 'group') unless hash[:structure].nil? || hash[:structure].empty?
      builder({:mount => hash[:mounts].to_hash}, output) unless hash[:mounts].nil? || hash[:mounts].empty?
      output.join("\n") << "\n"
    end

    def builder(hash, array, indent=0, prefix=nil)
      prefix = "#{prefix} " if prefix
      hash.to_hash.each_pair do |k,v|
        if(v.is_a?(Hash))
          array << "#{' ' * indent}#{prefix}#{k} {"
          self.builder(v, array, indent + 2)
          array << "#{' ' * indent}}"
        else
          array << "#{' ' * indent}#{prefix}#{k} = #{v};"
        end
      end
      array.join("\n") << "\n"
    end
  end
end
