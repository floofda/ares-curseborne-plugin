module AresMUSH
  module CoD
    class RollCmd
      include CommandHandler

      attr_accessor :wp, :rote, :again, :char, :target, :char_roll_str, :target_roll_str

      def parse_args
        self.char = enactor_name

        allowed_switches = ['strict', '9', '8', 'rote', 'wp']
        matches = /(\/(?<switches>([\/\d\w]+)))?\s+(?<args>.+)*/.match(cmd.raw.strip)
        switches = (matches && matches[:switches]) ? matches[:switches].split('/') : []

        if !switches.empty?
          invalid = switches - allowed_switches
          if !invalid.empty?
            return CoD.system_emit t('cod.invalid_roll_switches', switches: invalid.join(', ')), client
          end
        end

        self.wp = switches.include? 'wp'
        self.rote = switches.include? 'rote'
        self.again = (['strict', '9', '8'] & switches).first || '10'

        set_values = lambda { |str, name|
          return if str.nil?
          c, roll_str = str.split('/')
          return [c.strip, roll_str.strip] if roll_str || name.nil?
          return [name.strip, c.strip]
        }

        return if !matches || !matches[:args]
        side_1, side_2 = matches[:args]&.split(/@|vs/)
        self.char, self.char_roll_str = set_values.call(side_1, self.char)
        self.target, self.target_roll_str = set_values.call(side_2, nil)
      end

      def required_args
        [ self.char, self.char_roll_str ]
      end

      def handle
        if self.char != enactor_name && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.permission_denied'), client
        end

        char = Character.named(self.char)
        return CoD.system_emit(t('cod.invalid_character', char: self.char), client) if !char

        if !char.is_approved?
          return CoD.system_emit t('cod.character_must_be_approved', name: char.name), client
        end

        if self.wp && (CoD.get_rating(char.sheet, 'curr_wp') < 1)
          return CoD.system_emit t('cod.insufficient_resource', type: 'Willpower'), client
        end

        res, error, dice = CoD.build_roll_emit({
          enactor: enactor,
          char: char,
          target: self.target,
          opposed: cmd.args.include?('vs'),
          modified: cmd.args.include?('@'),
          wp: self.wp,
          rote: self.rote,
          again: self.again,
          char_roll_str: self.char_roll_str,
          target_roll_str: self.target_roll_str
        })

        return CoD.system_emit(error, client) if error
        CoD.roll_notify(enactor_room.scene, char, dice) if enactor_room.scene
        CoD.emit_message(res, client, enactor_room, 'roll results')
      end
    end
  end
end
