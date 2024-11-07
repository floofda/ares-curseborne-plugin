module AresMUSH
  module CoD

    def self.roll_notify scene, roller, dice
      return if !scene
      roll = { scene_id: scene.id, dice: dice[:dice] }
      if CoD.is_npc? roller
        settings = Global.read_config('cod', 'char_settings').with_indifferent_access[:dice]
      else
        settings = roller.cod_settings[:dice]
      end

      roll[:settings] = settings

      Global.client_monitor.notify_web_clients(:dice_roll, roll.to_json, true) do |c|
        next if !c || (!c.cod_settings&.dig(:dice, :use_others) && roller.id != c.id)
        scene.participant_names.include?(c.name) || Scenes.is_watching?(scene, c)
      end
    end

    def self.format_dice(dice, min = 8)
      failures = dice.select { |d| d < min }.sort.join(' ')
      successes = dice.select { |d| d >= min }.sort.join(' ')
      "%xn[%x8 #{failures}%xn%xc" + (!failures.empty? && !successes.empty? ? ' ' : '') + "#{successes} %xn]"
    end

    def self.pretty_print_values(values)
      values.reduce(''){ |c, n|
        if n[:stat]
          primary, secondary = n[:stat].split('.')
          stat = secondary ? "#{primary} (#{secondary})" : primary
        end
        c += c == '' ? "#{stat || n[:literal]}" : " #{n[:mod]} #{stat || n[:literal].abs}"
      }
    end

    def self.roll(pool, again = 10)
      pool = 100 if pool > 100
      chance = pool < 1

      if chance
        res = rand(10) + 1
        return { dice: [res], success: res == 10 ? 1 : 0 }
      end

      results = { dice: [], success: 0 }
      roll = lambda { |n|
        n.times.map {
          die = rand(10) + 1
          results[:dice] << die
          roll.call(1) if die >= again
        }
      }
      roll.call(pool)
      results[:success] = results[:dice].select { |d| d >= 8 }.size
      results
    end

    def self.parse_roll_string(sheet, roll_str)
      values = []
      roll_str.strip.gsub(/([+-])\s+/, '\1').scan(/[+-]?[\w\. ]+/i).each { |val|
        val = val.strip
        stat = is_numeric?(val) ? val.to_i : get_stat(sheet, val.gsub(/[+-]/, ''))
        if stat && !stat.is_a?(Integer)
          if stat.class.name == 'AresMUSH::Skill'
            primary, secondary = parse_stat(stat.name)
            if stat.rating == 0
              stat.name = "#{stat.name}.#{t('cod.unskilled')}"
            elsif !secondary.nil? && get_stat(sheet, "#{t('cod.area_of_expertise')}.#{secondary}", 'Merit')
              stat.name += " #{t('cod.expert')}"
            end
          end
          values << {
            stat: stat.is_a?(Hash) ? stat[:name] : stat.name,
            category: stat.class.name.gsub('AresMUSH::', ''),
            mod: val.start_with?('-') ? '-' : '+'
          }
        else
          values << (stat.is_a?(Integer) ? { literal: stat, mod: stat >= 0 ? '+' : '-' } : { invalid: val })
        end
      }
      order = [:stat, :literal, :invalid]
      values.sort!{ |a, b| order.index(a.keys.first) <=> order.index(b.keys.first) }
    end

    def self.parse_roll_errors(values)
      invalid = values.map { |val| val[:invalid] if val.key?(:invalid) }.compact
      t('cod.invalid_roll_terms', values: invalid.join(', ')) if !invalid.empty?
    end

    def self.get_dice_pool(sheet, values)
      pool = 0
      values.map do |term|
        type, value = term.first
        if type == :literal
          pool += value
        elsif type == :stat
          if term[:category] == 'Skill'
            value = value.gsub(" #{t('cod.expert')}", '')
            skill = get_stat(sheet, value)
            count = skill.rating
            primary, secondary = parse_stat(value)
            if skill.rating == 0
              count += skill.category == 'mental' ? -3 : -1
            elsif !secondary.nil?
              count += 1
              count += 1 if get_stat(sheet, "#{t('cod.area_of_expertise')}.#{secondary}", 'Merit')
            end
          else
            count = get_rating(sheet, value)
          end
          pool += count if count.is_a?(Integer)
        end
      end
      pool
    end
  end
end
