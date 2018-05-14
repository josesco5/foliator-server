module Document
  module Foliator
    class NumberToHuman

      def self.number_to_human(numero)
        de_tres_en_tres = numero.to_i.to_s.reverse.scan(/\d{1,3}/).map{|n| n.reverse.to_i}

        millones = [
          {true => nil, false => nil},
          {true => 'millon', false => 'millones'},
          {true => "billon", false => "billones"},
          {true => "trillon", false => "trillones"}
        ]

        centena_anterior = 0
        contador = -1
        palabras = de_tres_en_tres.map do |numeros|
          contador += 1
          if contador%2 == 0
            centena_anterior = numeros
            [centena_a_palabras(numeros, :millions), millones[contador/2][numeros==1]].compact if numeros > 0
          elsif centena_anterior == 0
            [centena_a_palabras(numeros, :thousands), "mil", millones[contador/2][false]].compact if numeros > 0
          else
            [centena_a_palabras(numeros, :thousands), "mil"] if numeros > 0
          end
        end

        palabras.compact.reverse.join(' ')
      end

      def self.centena_a_palabras(numero, thousand_fix=false)
        especiales = {
          11 => 'once', 12 => 'doce', 13 => 'trece', 14 => 'catorce', 15 => 'quince',
          10 => 'diez', 20 => 'veinte', 100 => 'cien'
        }
        if especiales.has_key?(numero)
          return especiales[numero]
        end

        centenas = [nil, 'ciento', 'doscientos', 'trescientos', 'cuatrocientos', 'quinientos', 'seiscientos', 'setecientos', 'ochocientos', 'novecientos']
        decenas = [nil, 'dieci', 'veinti', 'treinta', 'cuarenta', 'cincuenta', 'sesenta', 'setenta', 'ochenta', 'noventa']
        unidades = [nil, 'uno', 'dos', 'tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', 'nueve']

        centena, decena, unidad = numero.to_s.rjust(3,'0').scan(/\d/).map{|i| i.to_i}

        palabras = []
        palabras << centenas[centena]

        if especiales.has_key?(decena*10 + unidad)
          palabras << especiales[decena*10 + unidad]
        else
          unidad_string = unidades[unidad]
          if thousand_fix == :thousands && unidad_string == 'uno'
            unidad_string = ''
          end
          if thousand_fix == :millions && unidad_string == 'uno'
            # TODO: Check mil un and so
          end
          tmp = "#{decenas[decena]}#{' y ' if decena > 2 && unidad > 0}#{unidad_string}"
          palabras << (tmp.empty? ? nil : tmp)
        end
        palabras.compact.join(' ')
      end
    end
  end
end
