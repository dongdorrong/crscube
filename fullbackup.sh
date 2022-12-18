#!/bin/bash

backup_dir="/backup"
db_pw="~~~~~~~~~~~~~~"

logfile_name=`date +%Y_%m_%d`
backupfile_name=`date +%Y_%m_%d`

backupfile_rotate_period=15
oss_bucket_name="solution-dbbackup"

if [ ! -d ${backup_dir}/temp ]
then
    echo "================================================="
    echo "$(date +"%Y%m%d %H:%M:%S") [mariabackup] start"
    echo "$(date +"%Y%m%d %H:%M:%S") [mariabackup] log path : ${backup_dir}/log/mariabackup-${logfile_name}.log"

    # mariabackup 받고 해당 출력log를 log 파일에 저장
    mariabackup --backup --target-dir=${backup_dir}/temp --user=root --password=${db_pw} &> ${backup_dir}/log/mariabackup-${logfile_name}.log

    # config 파일도 복사
    cp -af /etc/my.cnf ${backup_dir}/temp
    echo "$(date +"%Y%m%d %H:%M:%S") [mariabackup] done"

fi

# 15일 이상된 파일 삭제
echo "$(date +"%Y%m%d %H:%M:%S") [backup file rotate] start"
find ${backup_dir}/result -name 'backup-20*' -type f -mtime +${backupfile_rotate_period} | xargs rm -f
find ${backup_dir}/log -name 'mariabackup-*' -type f -mtime +${backupfile_rotate_period} | xargs rm -f
echo "$(date +"%Y%m%d %H:%M:%S") [backup file rotate] done"

# 백업한 폴더 압축
echo "$(date +"%Y%m%d %H:%M:%S") [backup file compress] start"
tar zcvf ${backup_dir}/result/backup-${backupfile_name}.tar.gz ${backup_dir}/temp &> ${backup_dir}/log/tar-${logfile_name}.log
echo "$(date +"%Y%m%d %H:%M:%S") [backup file compress] done"

# 다음 백업을 위해서 디렉토리 삭제
rm -rf ${backup_dir}/temp

# OSS Bucket에 백업 파일 업로드
echo "$(date +"%Y%m%d %H:%M:%S") [backup file upload] start"
ossutil cp /backup/result/backup-${backupfile_name}.tar.gz oss://${oss_bucket_name} --config-file=${backup_dir}/oss/config &> ${backup_dir}/log/oss-${logfile_name}.log
echo "$(date +"%Y%m%d %H:%M:%S") [backup file upload] end"
echo "==============================================="
echo
