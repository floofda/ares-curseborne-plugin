module AresMUSH
  module CoD
    class CombatCmd
      include CommandHandler

      attr_accessor :target

      def parse_args
        self.target = !cmd.args ? enactor_name : titlecase_arg(cmd.args)
      end

      def handle
        if self.target != enactor_name && !CoD.can_view_sheets?(enactor) && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.permission_denied'), client
        end

        combat = Combat.find(scene_id: enactor_room.scene.id).first if enactor_room.scene

        ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
          if !model.is_approved? && !CoD.is_st?(enactor)
            return CoD.system_emit t('cod.character_must_be_approved', name: model.name), client
          end
          template = CombatTemplate.new(combat, model, client, cmd.switch)
          client.emit template.render
        end
      end
    end
  end
end
