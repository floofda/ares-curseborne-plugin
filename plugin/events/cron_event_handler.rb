module AresMUSH
  module CoD
    class CronEventHandler
      def on_event(event)
        config = Global.read_config('cod', 'xp_cron')
        periodic_xp = Global.read_config('cod', 'periodic_xp')
        max_xp = Global.read_config('cod', 'max_xp')

        if Cron.is_cron_match? config, event.time
          Chargen.approved_chars.each do |char|
            next if max_xp && char.xp >= max_xp
            CoD.award_xp(Game.master.system_character, char.sheet, periodic_xp, 'Cron XP')
          end
        end
      end
    end
  end
end
