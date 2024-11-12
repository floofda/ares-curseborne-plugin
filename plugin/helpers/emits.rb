module AresMUSH
  module CoD

    def self.header_line(left, right = nil, r_color = nil)
      right = nil if right&.empty?
      r_color = r_color || ''
      color = Global.read_config('cod', 'formatting', 'line_color') || '%xc'

      left_out = "#{color}---%xn%xh[%xn %xh#{left}%xn %xh]%xn#{color}"
      right_out = right ? "%xn%xh[%xn #{r_color}#{right} %xn%xh]%xn#{color}--" : ''
      len = "#{left_out}#{right_out}".gsub(/(%x[\w\d])/, '').length
      "%r#{left_out}#{'-' * [(78 - len), 0].max}#{right_out}%xn"
    end

    def self.footer_line(text = nil)
      color = Global.read_config('cod', 'formatting', 'line_color') || '%xc'

      (text.nil? || text&.empty?) ?
        "#{color}#{'-' * 78}%xn" :
        "#{color}#{'-' * (37 - (text.length/2.0).floor)}%xn%xh[%xn %xh#{text}%xn %xh]%xn#{color}#{'-' * (37 - (text.length/2.0).ceil)}"
    end

    def self.wound_boxes(sheet)
      derive_track(sheet).map{ |b|
        next "%x8[%xn%xr%xh*%xn%x8]%xn" if b == 3
        next "%x8[%xn%xrX%xn%x8]%xn" if b == 2
        next "%x8[%xn%xy/%xn%x8]%xn" if b == 1
        "%x8[%xn %x8]%xn"
      }.join('')
    end


    def self.system_emit(message, client, room = nil, type = :error)
      level = { info: '%xc', warning: '%xy', error: '%xr' }[type]
      prefix = Global.read_config('cod', 'formatting', 'system_prefix') || "%xh[%xn#{level} System %xn%xh]%xn"

      if room
        emit_message "#{prefix} #{message}", client, room, true
        if type != :error
          combat = Combat.find(scene_id: room.scene&.id).first
          combat_notify(combat) if combat
        end
      else
        client.emit "#{prefix} #{message}"
      end
    end

    def self.emit_message(message, client, room, info = nil)
      room.emit message if room
      if room&.scene
        Scenes.add_to_scene(room.scene, message)
        combat = Combat.find(scene_id: room.scene&.id).first
        combat_notify(combat) if combat
      end
      Global.logger.info "CoD #{info}: #{message.gsub(/(%x[\w\d])/, '')}" if info
    end

    def self.build_harm_msg(opts = {})
      colors = ['%xr%xh', '%xr', '%xy']
      types = ['aggravated', 'lethal', 'bashing']
      info = nil
      case opts[:track].first
      when 3
        info = t('cod.character_has_died', name: opts[:target].name)
      when 2
        info = t('cod.character_is_dying', name: opts[:target].name)
      when 1
        info = t('cod.character_is_concussed', name: opts[:target].name)
      end

      header = header_line(opts[:enactor].name, opts[:type].capitalize, colors[types.index opts[:type]])
      damage_rec = "#{opts[:target].name} has taken #{opts[:amount] * -1} damage!"
      return header, "#{damage_rec}#{info ? " #{info}%r" : ''}"
    end

    def self.build_heal_msg(opts = {})
      header = header_line(opts[:enactor].name, opts[:type].capitalize, '%xg%xh')
      healing_rec = "#{opts[:target].name} has received #{opts[:amount]} healing!"
      return header, healing_rec
    end

    def self.build_adjust_health_emit(opts = {})
      target = Character.named(opts[:char]) || Npc.named(opts[:char])

      if !target
        return nil, t('cod.invalid_character', char: opts[:char])
      elsif !target.is_approved?
        return nil, t('cod.character_must_be_approved', name: target.name)
      end

      types = ['aggravated', 'lethal', 'bashing']
      type = get_from_list(types, (opts[:type] || 'x')) || 'bashing'
      adjust_health(target.sheet, type, opts[:value])
      track = derive_track(target.sheet).reverse!

      index = track.slice(0, 3).index { |i| i != 0 }
      penalty = index.nil? ? nil : t('cod.wound_penalty', penalty: 3 - index)
      footer = footer_line(penalty)

      msg_opts = { enactor: opts[:enactor], type: type, target: target, amount: opts[:value], track: track }
      header, rec = opts[:value] >= 0 ? build_heal_msg(msg_opts) : build_harm_msg(msg_opts)
      "#{header}%r #{rec}%r#{footer}"
    end

    def self.build_roll_emit(opts = {})
      target_dice = 0
      vs = nil
      mark = opts[:target] ? (opts[:opposed] ? 'vs' : '@') : ''
      char = opts[:char]

      get_pool = lambda { |sheet, roll_str|
        values = parse_roll_string(sheet, roll_str)
        error = parse_roll_errors(values)
        return nil, error if error
        { pool: get_dice_pool(sheet, values), values: values }
      }

      get_degree = lambda { |s, dice|
        return t('cod.dramatic_failure', dice: 0) if dice.size == 1 && dice[0] == 1
        return t('cod.failure', dice: 0) if s == 0
        s >= 5 ? t('cod.exceptional_success', dice: s) : t('cod.success', dice: s)
      }

      format_pool_msg = lambda { |name, values, degree, dice|
        msg = " %xn#{name}%x8 => %xn #{pretty_print_values(values)}"
        msg += "%r#{' ' * (name.length + 5)} #{degree}" if degree
        msg += "%r#{' ' * (91 - [dice.length, 91].min)} #{dice}" if dice
        msg
      }

      target = Character.named(opts[:target]) || Npc.named(opts[:target])
      if !target && opts[:target]
        return nil, t('cod.invalid_character', char: opts[:target])
      elsif target && !target.is_approved?
        return nil, t('cod.character_must_be_approved', name: target.name)
      elsif target
        return nil, t('cod.missing_opposed_roll') if !opts[:target_roll_str]
        res, error = get_pool.call(target.sheet, opts[:target_roll_str])
        return nil, error if error
        target_dice -= res[:pool] if mark == '@'
        vs = '%r' + format_pool_msg.call(target.name, res[:values], nil, nil)

        if mark == 'vs'
          result = roll(res[:pool], 10)
          dice = format_dice(result[:dice], res[:pool] <= 0 ? 10 : 8)
          opposed = get_degree.call(result[:success], result[:dice])
          vs = '%r' + format_pool_msg.call(target.name, res[:values], opposed, dice)
        end
      end

      res, error = get_pool.call(char.sheet, opts[:char_roll_str])
      return nil, error if error
      set_stat(char.sheet, 'field', 'curr_wp', -1) if opts[:wp]
      pool = res[:pool] + target_dice + (opts[:wp] ? 3 : 0)
      result = roll(pool, opts[:again] == 'strict' ? 11 : opts[:again].to_i)


      if opts[:rote] && pool > 0
        rote = roll(pool - result[:success], 11)
        result[:dice] = result[:dice] + rote[:dice]
        result[:success] = result[:success] + rote[:success]
      end

      degree = get_degree.call(result[:success], result[:dice])
      dice = format_dice(result[:dice], pool <= 0 ? 10 : 8)
      again = "#{opts[:again]}"
      qualities = pool <= 0 ? ' Chance' : ''
      qualities += (opts[:wp] ? ' Willpower': '')
      qualities += ' Rote' if opts[:rote] && pool > 0
      qualities += " #{again == 'strict' ? 'Strict' : "#{again}-again"}" if again != '10' && pool > 0

      header_line = header_line(opts[:enactor].name, qualities.strip)
      roll_str = format_pool_msg.call(char.name, res[:values], degree, dice)
      footer_line = footer_line(mark)
      return "#{header_line}%r#{roll_str}#{vs ? "%r#{vs}" : ''}%r#{footer_line}", nil, result
    end

  end
end
