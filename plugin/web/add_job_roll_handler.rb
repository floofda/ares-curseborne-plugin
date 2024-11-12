module AresMUSH
  module CoD
    class AddJobRollHandler
      def handle(request)
        job = Job[request.args[:id]]
        char = Character.named(request.args[:char]) || Npc.named(request.args[:char])
        enactor = request.enactor
        data = request.args

        error = Website.check_login(request)
        return error if error

        return { error: t('webportal.not_found') } if !job
        return { error: t('jobs.cant_view_job') } if !Jobs.can_access_job? enactor, job, true
        return { error: t('cod.invalid_character', char: data[:char]) } if !char
        return { error: t('cod.character_must_be_approved', name: char.name) } if !char.is_approved?

        if CoD.to_b(data[:wp]) && (CoD.get_rating(char.sheet, 'curr_wp') < 1)
          return { error: t('cod.insufficient_resource', type: 'Willpower') }
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

        return { error: error } if error

        Jobs.comment job, enactor, res, false
        dice
      end
    end
  end
end
