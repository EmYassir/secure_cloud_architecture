#!/bin/bash
root_dir="/"
our_login="equipekim"
i=0

function rename_and_send_result_archive(){
    #echo "Sending back the results in to $user_name "
    old_archive_name="$1";
    user_name=$(echo $old_archive_name | cut -d"_" -f1);
    user_name=${user_name##*/}
    user_path="${root_dir}home/$user_name";
    new_archive_name=$(echo $old_archive_name | cut -d"_" -f2);
    new_archive_name="${new_archive_name}.tar.gz"
    #group=$(get_group ${user_name})
    #echo $group
    echo "Sending back the results old $old_archive_name to new $new_archive_name to $user_name"
    cmd=`cat /var/groups_externes | grep  $user_name`
    if [ $? -eq 0 ]; then
    #if [ ${user_name} -eq $i ]; then
        	#recuperation du nom de domaine
                   #domain="$line";
                   #done < ${user_path}/host
		   echo "Job Delivering to "
                   cmd=`scp -i /home/equipekim/.ssh/id_rsa ${old_archive_name} $our_login@$user_name:/home/${our_login}/out/${new_archive_name}`
		   # Test execution de commande
                   if [ $? -eq 0 ]; then 
			echo "Transfer completed"
                   	cmd=`rm -rf ${old_archive_name}`;
         	   else 
			echo "Transfer failed $#"
		   fi
		   i=1;
		   #break;
   else 
       cmd=`mv ${old_archive_name} ${root_dir}home/${user_name}/out/${new_archive_name}`
       setfacl -m u:www-data:rwx /home 
   fi
}

for i in {4..8..1}
do
	echo "Retrieving results from 10.0.0.$i"
	scp root@10.0.0.$i:/opt/* /ready/
	ssh -f root@10.0.0.$i 'rm -rf /opt/*'
	#echo "$i"
done

cmd=`ls ${root_dir}ready/ | wc -l`
if [ $cmd = 0  ]; then
     echo "repertoire ${root_dir}ready/ vide"
else
    for result in "${root_dir}ready/"*; do
       #renommage nom original et envoi de l'archive
       rename_and_send_result_archive ${result}
    done
fi

