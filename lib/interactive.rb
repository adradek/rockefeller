class Interactive
  class << self
    def puts_header
      system("clear")
      puts "💰💰💰 Добро пожаловать в Rockefeller Wallet (Bitcoin Signet) 💰💰💰\n\n"
    end

    def standard_prompt
      print "    > "
    end

    def within_template
      puts_header
      yield
      standard_prompt
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
        puts "    Задайте пароль (по умолчанию = ''):"
      end
    end

    def show_restore_wallet(name)
      within_template do
        puts "    📁 Загружаем кошелек [#{name}]"
        puts
        puts "    Введите пароль (по умолчанию = ''):"
      end
    end

    def ask_for_mnemonic
      puts
      puts "    Введите мнемоническую фразу или она сгенерируется автоматически:"
      standard_prompt
    end

    def show_generated_mnemonic(mnemonic)
      puts
      puts "    💡 Экономим ваше время, сгенерировали мнемонику автоматически (сохраните ее у себя):"
      puts "    #{mnemonic}"
      gets
    end

    def unable_to_restore_wallet
      puts
      puts "    ❌ Не удалось восстановить кошелек из файла. Возможно, неверный пароль"
      puts "    🤯 Попробуйте еще раз или создайте новый кошелек с теми же мнемоникой и паролем"
      puts "\n\n\n"
    end

    def connection_error(e)
      puts
      puts "    ❌ Не удалось прочитать балансы кошелька"
      puts "    🤯 Mnemonic::Client вернул ошибку:"
      puts "       #{e}"
      puts "       Возможно, сервис недоступен"
      puts "\n\n\n"
    end

    def wallet_restored(wallet)
      within_template do
        puts
        puts "    ✅ Кошелек [#{wallet.name}] восстановлен. Проверяем балансы..."
        puts
        show_wallet_data(wallet)
      end
    end

    def wallet_created(wallet)
      within_template do
        puts
        puts "    ✅ Кошелек [#{wallet.name}] создан. Немного подождите..."
        puts
        show_wallet_data(wallet)
      end
    end

    def show_wallet(wallet)
      wallet.update_balances
      within_template { show_wallet_data(wallet) }
    end

    def show_wallet_data(wallet)
      puts "    💰 Балансы кошелька [#{wallet.name}] (выводятся в mBTC)"
      puts
      wallet.to_s.split("\n").each do |line|
        puts "       #{line}"
      end
      puts
      puts "    💸 Время тратить деньги!"
      puts "    Введите адрес получателя и сумму в satoshi через пробел: tb1q... 10000"
      puts "    Адрес для сдачи вводите последним (можно без суммы), '' - к следующему шагу, [q, quit, x, exit, Ctrl+C] - выход:"
      puts
    end

    def ask_for_source_address
      puts
      puts "    Введите адрес списания: tb1q..."
      puts
      standard_prompt
    end

    def transaction_report(payload)
      puts
      puts "    🌐 Транзакция отправлена в mempool.space - id: #{payload}"
      puts "    https://mempool.space/signet/tx/#{payload}"
    end
  end
end
