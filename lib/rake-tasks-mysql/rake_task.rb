namespace :mysql do
  def parse_mysql_args(args)
    if args.length > 2
      args = args[2..-1]
    elsif args.length == 1
      args = args[1..-1]
    end
    args
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
end
