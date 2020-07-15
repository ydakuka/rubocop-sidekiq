module RuboCop
  module Cop
    module Sidekiq
      class IncludedInModule < ::RuboCop::Cop::Cop
        include Helpers

        MSG = 'Do not include Sidekiq::Worker in a module.'.freeze

        def_node_matcher :module_include?, <<~PATTERN
          {
            (module _ $#includes_sidekiq?)
            (block (send (const nil? :Module) :new ...) _ $#includes_sidekiq?)
          }
        PATTERN

        def on_module(node)
          return unless (include = module_include?(node))
          return if allowed_module?(node)

          add_offense(include)
        end
        alias_method :on_block, :on_module

      private

        def allowed_module_names
          Array(cop_config['Whitelist']).map(&:to_s)
        end

        def allowed_module?(node)
          identifier = module_identifier(node)
          return false unless identifier

          allowed_module_names.include?(identifier)
        end

        def module_identifier(node)
          if node.module_type?
            node.identifier.const_name
          elsif node.block_type?
            node.parent.defined_module_name if node.parent && node.parent.casgn_type?
          end
        end
      end
    end
  end
end
