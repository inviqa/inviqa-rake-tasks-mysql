namespace :mysql do
  def parse_mysql_args(args)
    if args.length > 2
      args = args[2..-1]
    elsif args.length == 1
      args = args[1..-1]
    end
    args
  end

  def parse_mysqldump_args(args)
    Slop.parse args do |options|
      options.string '-f', '--filename', 'The filename to save the MySQL dump as.', default: 'sqldump.sql.gz'
      yield options if block_given?
    end
  end

  def parse_mysqlrestore_args(args)
    Slop.parse args do |options|
      options.string '-f', '--filename', 'The filename to restore into the MySQL database.', default: 'sqldump.sql.gz'
      yield options if block_given?
    end
  end

  task :console do
    args = parse_mysql_args(ARGV)
    STDOUT.puts "==> Opening mysql console...\n\n"
    command = 'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" ' + args.join(' ')
    services_from_args(services: %w[mysql]).exec(
      'root',
      "bash -c '#{command}'"
    )
    exit $?.to_i
  end

  task :dump do
    args = parse_argv
    args = parse_mysqldump_args(args)

    STDOUT.puts "==> Performing a mysqldump to filename #{args[:filename]}\n\n"

    command = 'mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" | gzip -9 > ' + Shellwords.escape(args[:filename])
    docker = services_from_args(services: %w[mysql])
    docker.exec(
      'root',
      "bash -c '#{command}'"
    )
    if $?.to_i != 0
      STDERR.puts "\n\n==> The dump could not be created\n\n"
      exit $?.to_i
    end
    STDOUT.puts "==> mysqldump to #{args[:filename]} complete, copying to the host\n\n"

    docker.download(args[:filename], args[:filename])
    if $?.to_i != 0
      STDERR.puts "\n\n==> The dump could not be copied to the host\n\n"
      exit $?.to_i
    end

    STDOUT.puts "\n\n==> The dump was created and copied to #{args[:filename]}\n\n"
  end

  task :restore do
    args = parse_argv
    args = parse_mysqlrestore_args(args)

    STDOUT.puts "==> Applying the mysqldump from #{args[:filename]}\n\n"

    docker = services_from_args(services: %w[mysql])
    docker.upload(args[:filename], args[:filename])
    if $?.to_i != 0
      STDERR.puts "\n\n==> The dump could not be copied to the container\n\n"
      exit $?.to_i
    end

    command = 'gzip --decompress --stdout ' + Shellwords.escape(args[:filename]) + ' | mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'
    docker.exec(
      'root',
      "bash -c '#{command}'"
    )
    if $?.to_i != 0
      STDERR.puts "\n\n==> The dump could not be applied\n\n"
      exit $?.to_i
    end

    STDOUT.puts "\n\n==> The dump #{args[:filename]} was applied to the database\n\n"
  end
end
