while read line; do
  #check if repo already exists
  #extract the repo name by splitting the line on the last /
  repo_name=$(echo $line | awk -F'/' '{print $NF}')
  if [ -d /data/containers/$repo_name ]; then
    echo "$line already exists"
    #pull the latest changes
    cd /data/containers/$repo_name
    git pull
    echo "pulled latest changes"
  else
    echo "cloning $line"
    git clone https://$github_username:$github_token@github.com/$line.git /data/containers
  fi
done < /tmp/repos.txt