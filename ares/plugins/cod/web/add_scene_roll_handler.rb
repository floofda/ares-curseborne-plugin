module AresMUSH
  module CoD
    class AddSceneRollHandler
      def handle(request)
        scene = Scene[request.args[:id]]
        char = Character.named(request.args[:char]) || Npc.named(request.args[:char])
        enactor = request.enactor
        data = request.args

        error = Website.check_login(request)
        return error if error

        return { c_error: t('webportal.not_found') } if !scene
        return { c_error: t('scenes.access_not_allowed') } if !Scenes.can_read_scene? enactor, scene
        return { c_error: t('scenes.scene_already_completed') } if scene.completed
        if !CoD.is_st?(enactor) && (CoD.is_npc?(char) && char.creator_id != enactor.id)
          return { c_error: t('cod.no_permission_to_change_x', name: char.name) }
        end

        return CoD.system_emit(t('cod.invalid_character', char: data[:char]), nil, scene.room) if !char

        if !char.is_approved?
          return CoD.system_emit t('cod.character_must_be_approved', name: char.name), nil, scene.room
        end

        if CoD.to_b(data[:wp]) && (CoD.get_rating(char.sheet, 'curr_wp') < 1)
          return CoD.system_emit t('cod.insufficient_resource', type: 'Willpower'), nil, scene.room
        end

        res, error, dice = CoD.build_roll_emit({
          enactor: enactor,
          char: char,
          target: data[:target].empty? ? nil : data[:target],
          opposed: CoD.to_b(data[:opposed]),
          modified: CoD.to_b(data[:modified]),
          wp: CoD.to_b(data[:wp]),
          rote: CoD.to_b(data[:rote]),
          again: data[:again].to_i,
          char_roll_str: data[:char_roll_str],
          target_roll_str: data[:target_roll_str]
        })

        return { c_error: error } if error
        CoD.roll_notify scene, char, dice
        CoD.emit_message res, nil, scene.room, true
        dice
      end
    end
  end
end
