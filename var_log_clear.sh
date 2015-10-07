#!/bin/bash

#Seo Hyun Gwan

#현재 완성한 소스는 CentOS 6~7을 기준으로 작성함.
#타 배포판의 로그도 삭제할 수 있도록 정규표현식을 개선해야함.

TARGET=/var/log

# maillog-20150824.gz, maillog-20151002와 같은 형식의 파일을 삭제한다.
function delete_log_files_incldue_date()
{
	DAILY_LOG_NAME_LISTS=daily_log_name_lists.txt
	rm -rf $TARGET/*.gz # ex) maillog-20150824.gz 삭제

	ls --color=no $TARGET | egrep -o [a-z]+-[0-9]+ > $DAILY_LOG_NAME_LISTS
	readarray -t daily_log_name_lists < $DAILY_LOG_NAME_LISTS
	for ((idx=0; idx < ${#daily_log_name_lists[@]}; idx++))
	{
		rm -rf ${daily_log_name_lists[$idx]} # ex) maillog-20151002 삭제
	}
}

# maillog-20150824.gz, maillog-20151002 형식이 아닌 파일들을 초기화한다.
# ex) boot.log, cron, dmesg, messages 등등
function clear_log_files()
{
	LOG_FILE_LISTS=log_file_lists.txt
	ls -al --color=no $TARGET | egrep '^-' | awk -F " " '{print $9}' > $LOG_FILE_LISTS

	readarray -t log_file_lists < $LOG_FILE_LISTS

	for ((idx=0; idx < ${#log_file_lists[@]}; idx++))
	{
		 echo > ${log_file_lists[$idx]}
	}
}

# /var/log에 위치한  서브 디렉토리의 로그를 초기화한다.
function delete_sub_directory_logs()
{
	CURRENT_DIR=`pwd > current_dir.txt`
	VAR_LOG_SUB_DIR_NAME_LIST=var_log_sub_dir_name_list.txt
	ls -l --color=no $TARGET | egrep '^d' | awk -F " " '{print $9}' > $VAR_LOG_SUB_DIR_NAME_LIST

	readarray -t var_log_sub_dir_name_list < $VAR_LOG_SUB_DIR_NAME_LIST

	for ((idx=0; idx < ${#var_log_sub_dir_name_list[@]}; idx++))
	{
		cd $TARGET/${#var_log_sub_dir_name_list[$idx]}
		delete_log_files_incldue_date
		clear_log_files
	}

	cd $CURRNET_DIR
}

delete_log_files_include_date
clear_log_files
delete_sub_directory_logs
