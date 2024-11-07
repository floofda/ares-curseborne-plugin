module AresMUSH
  module CoD
    class SheetCmd
      include CommandHandler

      attr_accessor :target

      def parse_args
        self.target = !cmd.args ? enactor_name : titlecase_arg(cmd.args)
      end

      def handle
        if self.target != enactor_name && !CoD.can_view_sheets?(enactor) && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.permission_denied'), client
        end

        ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
          if !model.chargen_locked && !enactor.is_admin?
            return CoD.system_emit t('cod.character_must_be_approved', name: model.name), client
          end

          template = SheetTemplate.new(model, client, cmd.switch)
          client.emit template.render
        end
      end
    end
  end
end
