namespace :bitcoin do
  desc "Synchronizes the transactions in the client with the transactions stored in the database"
  task :synchronize_transactions => :environment do
    BitcoinTransfer.synchronize_transactions!
  end

  desc "Backs the wallet up and sends it through e-mail"
  task :backup => :environment do
    recipient = YAML::load(File.open(File.join(Rails.root, "config", "backup.yml")))["recipient"]

    # Check that we have GPG in the path and that the key exists
    if system("gpg --version") and system("gpg --fingerprint \"#{recipient}\"")
      temp_file = File.join(Dir.tmpdir, (rand * 10 ** 9).to_i.to_s)
      Bitcoin::Client.new.backup_wallet temp_file
      system("gpg -e -r \"#{recipient}\" #{temp_file}")
      BackupMailer.wallet_backup(recipient, "#{temp_file}.gpg").deliver
      system("rm -f #{temp_file}*")
    end
  end
end