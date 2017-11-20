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

  task :console do
    args = parse_mysql_args(ARGV)
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
    command = 'mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" | gzip -9 > ' + args[:filename]
    docker = services_from_args(services: %w[mysql])
    docker.exec(
      'root',
      "bash -c '#{command}'"
    )
    if $?.to_i != 0
      STDERR.puts "\n\n==> The dump could not be created\n\n"
      exit $?.to_i
    end

    docker.download(args[:filename], args[:filename])
    if $?.to_i != 0
      STDERR.puts "\n\n==> The dump could not be copied to the host\n\n"
      exit $?.to_i
    end

    STDERR.puts "\n\n==> The dump was created and copied to #{args[:filename]}\n\n"
  end
end
