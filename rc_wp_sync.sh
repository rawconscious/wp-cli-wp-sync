#!/bin/bash

echo "enter the project name:"
read project_name

rc_uuid=$(date '+%Y-%m-%d-%H-%M-%S')-$( cat /proc/sys/kernel/random/uuid )

sudo ssh $project_name 'bash -s' << EOF

cd /var/www/$project_name
sudo wp db export $rc_uuid.sql --allow-root

EOF

sudo scp $project_name:/var/www/$project_name/$rc_uuid.sql /var/www/$project_name/

sudo ssh $project_name 'bash -s' << EOF

cd /var/www/$project_name
sudo rm $rc_uuid.sql

EOF

cd /var/www/$project_name/

echo "enter the project remote domain ( Example example.com):"
read project_root_domain
echo "enter the project local domain with port ( Example localhost:8080):"
read project_local_domain

wp db import $rc_uuid.sql --allow-root

wp search-replace "https://www.$project_root_domain" "http://$project_local_domain" --skip-columns=guid --allow-root
wp search-replace "http://www.$project_root_domain" "http://$project_local_domain" --skip-columns=guid --allow-root
wp search-replace "https://$project_root_domain" "http://$project_local_domain" --skip-columns=guid --allow-root
wp search-replace "http://$project_root_domain" "http://$project_local_domain" --skip-columns=guid --allow-root

sudo rsync -a lolly:/bitnami/wordpress/wp-content/uploads/ /var/www/lolly/wp-content/uploads/
sudo chown -R www-data:www-data wp-content
sudo wp option set blog_public 0 --allow-root




