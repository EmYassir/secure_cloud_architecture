#!/bin/bash


root_dir="/" # A remplacer par "/"
log_file="${root_dir}log.txt"        # A commenter

# Routine de test de groupe
function get_group {
    user_name=$1
    isInKim=`groups ${user_name} | grep kim`
    echo $isInKim
    isInOther=`groups ${user_name} | grep other`
    echo $isInOther    

    if [ -n "$isInKim" ];then
	echo "kim"
    elif [ -n "$isInOther" ];then
	echo "other"
    fi
}


# 1) Teste si c'est bien une archive tar.gz
test_archive_format(){
    archive_path="$1";
    archive_name=`basename ${archive_path} .tar.gz`
    archive_name="${archive_name}.tar.gz"
    if [[ $archive_name =~ ^[a-zA-Z0-9]*.tar.gz$ ]]; then
	echo 0;
    else
	echo 1;
    fi
}

# 2) Test si le contenu est dans la norme
test_archive_elements(){
    archive_name="$1"
    test_job_xml=`tar -tf ${archive_name} | grep job.xml`
    test_files_run=`tar -tf ${archive_name} | grep files/run.sh`
    
    if [ ! "${test_job_xml}" = "job.xml" ]; then
	echo 1
    elif [ ! "${test_files_run}" = "files/run.sh" ]; then
	echo 1
    else
	echo 0
    fi
}


# 3) Test s'il n y a pas usurpation
test_correspondance(){
    archive_name="$1"
    user_dir_name="$2"
    #cmd=`tar -xzvf ${archive_name} "job.xml"`
    #user_name=${user_dir_name##*/};
    
    #out=`less job.xml | grep username`
    #out=$(echo $out | cut -d">" -f2);
    #out=$(echo $out | cut -d"<" -f1);

    #cmd=`rm -rf job.xml`;
    
    if [ ! "${user_name}" = "${out}" ]; then
	echo 1
    else
	echo 0
    fi
}

# 4) Renomme l'archive et la place en attente de scheduling
rename_and_move_exec_archive(){
    echo "Function Scheduling launched"
    old_archive_name="$1";    
    user_path="$2";
    user_name=${user_path##*/};
    #renommage
    new_archive_name=`basename ${old_archive_name} .tar.gz`
    r=( $(openssl rand 100000 | sha1sum) );
    new_archive_name="${user_name}_${new_archive_name}_${r[0]:0:15}.tar.gz";
    echo "The archive $new_archive_name will be moved in /to_schedule"
    cmd=`mv ${old_archive_name} ${user_path}/in/${new_archive_name}`;

    cmd=`mv ${user_path}/in/${new_archive_name} ${root_dir}to_schedule/`;
    echo "Launching scheduler"
    #su frontend
    scheduler >/home/frontend/out.txt 2>/home/frontend/err.txt
    #exit
    echo "The scheduler has returned"
}


# 6) Recupere l'archive, enleve l'id et le hash, et l'envoie au destinataire
rename_and_send_result_archive(){
    old_archive_name="$1";    
    user_name=$(echo $old_archive_name | cut -d"_" -f1);
    user_name=${user_name##*/}
    user_path="${root_dir}home/$user_name";
    new_archive_name=$(echo $old_archive_name | cut -d"_" -f2);
    new_archive_name="${new_archive_name}.tar.gz"
     
    group=$(get_group ${user_name})
    echo $group
    #if [ ${group} -ne "kim" ]; then
        #recuperation du nom de domaine
	domain="";
	while read line  
	do
	    domain="$line";
	    break;
	done < ${user_path}/host

	#cmd=`scp ${new_archive_name} ${user_name}@${domain}:/home/${user_name}/out/`
    
        # Test execution de commande
	#if [ $? -eq 0 ]; then 
	#    cmd=`rm -rf ${new_archive_name}`;
	#fi
    #else
	cmd=`mv ${new_archive_name} ${root_dir}home/${user_name}/out/`	
    #fi
}




# 7) teste si l'utilisateur interne ne tente pas une usurpation
test_usurpation(){
    user_name=$1
    user_dirs=$(find ${root_dir}home/* -type d -prune);
    i=0;
    for dir in ${user_dirs}; do
	if [ ${dir} = "${user_name}" ]; then    
	    i=$(($i+1))
	fi
    done
    if [ $i = 0 ]; then    
	echo  1
    else
	echo 0
    fi
}


##### debut routine

echo "Routine Start"
user_dirs=$(find ${root_dir}home/* -type d -prune);
touch /home/frontend/`date`.log 

# passe 1 : recuperation des archives a envoyer
for user_name in ${user_dirs}; do

        # Boucle sur les fichiers en attente
	for in_file in "${user_name}/in/"*".tar.gz"; do
	    echo "Current path: $user_name"
            # test format de l'archive
	  
	    echo "Test format: $in_file"
	    test_var=$(test_archive_format ${in_file})
	    
	    if [ ${test_var} -ne 0 ]; then
		cmd=`rm -rf ${in_file}`;
		archive_name=`basename ${in_file} .tar.gz`
		break;
	    fi
	    echo "Test type Passed"	    
            echo "test contenu de l'archive"
	    test_var=$(test_archive_elements ${in_file});
	    if [ ${test_var} -ne 0 ]; then
		cmd=`rm -rf ${in_file}`;
		break;
	    fi
            echo "Test content passed"
	    echo "test correpondance started"
	    #test_var=$(test_correspondance ${in_file} ${user_name});
	    
	    if [  ${test_var} -ne 0 ]; then
		rm -rf ${in_file};
		cmd=`rm -rf ${in_file}`;
		break;
	    fi

	    echo "renommage et extraction du job"
	    cmd=$(rename_and_move_exec_archive ${in_file} ${user_name})
	    
	done
done


# passe 2 : recuperation des resultats et envois aux destinataires
        # Boucle sur les fichiers en attente

#cmd=`ls ${root_dir}ready/ | wc -l`
#if [ $cmd = 0  ]; then
#     echo "repertoire ${root_dir}ready/ vide"
#else
#    for result in "${root_dir}ready/"*; do
    # renommage nom original et envoi de l'archive
#	rename_and_send_result_archive ${result}
#    done
#fi

