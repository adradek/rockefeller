class Interactive
  class << self
    def puts_header
      system("clear")
      puts "💰💰💰 Добро пожаловать в Rockefeller Wallet (Bitcoin Signet) 💰💰💰\n\n"
    end

    def standrd_prompt
      print "    > "
    end

    def within_template
      puts_header
      yield
      standrd_prompt
    end

    def no_wallets
      within_template do
        puts "    🔒 У вас нет сохраненных кошельков"
        puts
        puts "    Отличный шанс завести первый. Придумайте имя"
      end
    end

    def show_wallets(wallets)
      within_template do
        puts "    🔒 Ваши cохраненные кошельки:"
        wallets.each { |w| puts "       [#{w}]" }
        puts
        puts "    Грузим один из них или создаем новый? Введите имя кошелька"
      end
    end

    def show_new_wallet(name)
      within_template do
        puts "    🚀 Создаем новый кошелек [#{name}]"
        puts
        puts "    Задайте пароль [по умолчанию = '']:"
      end
    end

    def show_restore_wallet(name)
      within_template do
        puts "    📁 Загружаем кошелек [#{name}]"
        puts
        puts "    Введите пароль [по умолчанию = '']:"
      end
    end

    def ask_for_mnemonic
      puts
      puts "    Введите мнемоническую фразу или она сгенерируется автоматически:"
      standrd_prompt
    end

    def show_generated_mnemonic(mnemonic)
      puts
      puts "    Экономим ваше время, сгенерировали мнемонику автоматически (сохраните ее у себя):"
      puts "    '#{mnemonic}'"
    end

    def unable_to_restore_wallet
      puts
      puts "    ❌ Не удалось восстановить кошелек из файла. Возможно, неверный пароль"
      puts "    🤯 Попробуйте еще раз или создайте новый кошелек с теми же мнемоникой и паролем"
    end

    def wallet_restored(wallet)
      within_template do
        puts
        puts "    ✅ Кошелек [#{wallet.name}] восстановлен. Проверяем балансы..."
        puts
        wallet.to_s.split("\n").each do |line|
          puts "       #{line}"
        end
        puts
        puts "    Время тратить деньги! Введите номер кошелька получателя ['' - выход]"
      end
    end
  end
end
