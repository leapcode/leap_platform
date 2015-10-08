module LeapCli; module Commands

  desc 'Database commands.'
  command :db do |db|
    db.desc 'Destroy one or more databases. If present, limit to FILTER nodes. For example `leap db destroy --db sessions,tokens testing`.'
    db.arg_name 'FILTER', :optional => true
    db.command :destroy do |destroy|
      destroy.flag :db, :arg_name => "DATABASES", :desc => 'Comma separated list of databases to destroy (no space). Use "--db all" to destroy all databases.', :optional => true
      destroy.flag :user, :arg_name => "USERS", :desc => 'Comma separated list of usernames. The storage databases for these user(s) will be destroyed.', :optional => true
      destroy.action do |global_options,options,args|
        dbs = (options[:db]||"").split(',')
        users = (options[:user]||"").split(',')
        if dbs.empty? && users.empty?
          bail!('Either --db or --user is required.')
        end
        nodes = manager.filter(args)
        if nodes.any?
          nodes = nodes[:services => 'couchdb']
        end
        unless nodes.any?
          bail! 'No db nodes selected.'
        end
        if users.any?
          unless global_options[:yes]
            say 'You are about to permanently destroy user databases for [%s] for nodes [%s].' % [users.join(', '), nodes.keys.join(', ')]
            bail! unless agree("Continue? ")
          end
          destroy_user_dbs(nodes, users)
        elsif dbs.any?
          unless global_options[:yes]
            if dbs.include?('all')
              say 'You are about to permanently destroy all database data for nodes [%s].' % nodes.keys.join(', ')
            else
              say 'You are about to permanently destroy databases [%s] for nodes [%s].' % [dbs.join(', '), nodes.keys.join(', ')]
            end
            bail! unless agree("Continue? ")
          end
          if dbs.include?('all')
            destroy_all_dbs(nodes)
          else
            destroy_dbs(nodes, dbs)
          end
          say 'You must run `leap deploy` in order to create the databases again.'
        end
      end
    end
  end

  private

  def destroy_all_dbs(nodes)
    ssh_connect(nodes) do |ssh|
      ssh.run('/etc/init.d/bigcouch stop && test ! -z "$(ls /opt/bigcouch/var/lib/ 2> /dev/null)" && rm -r /opt/bigcouch/var/lib/* && echo "All DBs destroyed" || echo "DBs already destroyed"')
    end
  end

  def destroy_dbs(nodes, dbs)
    nodes.each_node do |node|
      ssh_connect(node) do |ssh|
        dbs.each do |db|
          ssh.run(DESTROY_DB_COMMAND % {:db => db})
        end
      end
    end
  end

  def destroy_user_dbs(nodes, users)
    nodes.each_node do |node|
      ssh_connect(node) do |ssh|
        users.each do |user|
          ssh.run(DESTROY_USER_DB_COMMAND % {:user => user})
        end
      end
    end
  end

  DESTROY_DB_COMMAND = %{
if [ 200 = `curl -ns -w "%%{http_code}" -X GET "127.0.0.1:5984/%{db}" -o /dev/null` ]; then
  echo "Result from DELETE /%{db}:" `curl -ns -X DELETE "127.0.0.1:5984/%{db}"`;
else
  echo "Skipping db '%{db}': it does not exist or has already been deleted.";
fi
}

  DESTROY_USER_DB_COMMAND = %{/srv/leap/couchdb/scripts/destroy-user-db --username %{user}}
end; end
