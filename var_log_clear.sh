#!/bin/bash

#Seo Hyun Gwan

#현재 완성한 소스는 CentOS 6~7을 기준으로 작성함.
#기타 로그 파일 형식도 삭제할 수 있도록 정규표현식을 개선해야함.

BASE_TARGET=/var/log
TARGET=/var/log
IS_SUB_DIR=0 # 0 -> /var/log, 1 -> /var/log의 서브 디렉토리
SUB_DIR_PATH="/var/log"

function check_sub_dir()
{
	if [ $IS_SUB_DIR -eq 0 ]; then
		TARGET=$BASE_TARGET
	else
		TARGET=$TARGET
	fi
}

# maillog-20150824.gz, maillog-20151002와 같은 형식의 파일을 삭제한다.
function delete_log_files_incldue_date()
{
	check_sub_dir

	DAILY_LOG_NAME_LISTS=daily_log_name_lists.txt
	rm -rf $TARGET/*.gz # ex) maillog-20150824.gz 삭제

	ls --color=no $TARGET | egrep -o [a-z]+-[0-9]+ > $DAILY_LOG_NAME_LISTS
	readarray -t daily_log_name_lists < $DAILY_LOG_NAME_LISTS
	for ((idx=0; idx < ${#daily_log_name_lists[@]}; idx++))
	{
		rm -rf $TARGET/${daily_log_name_lists[$idx]} # ex) maillog-20151002 삭제
	}
}

# maillog-20150824.gz, maillog-20151002 형식이 아닌 파일들을 초기화한다.
# ex) boot.log, cron, dmesg, messages 등등
function clear_log_files()
{
	check_sub_dir

	LOG_FILE_LISTS=log_file_lists.txt
	ls -al --color=no $TARGET | egrep '^-' | awk -F " " '{print $9}' > $LOG_FILE_LISTS

	readarray -t log_file_lists < $LOG_FILE_LISTS

	for ((idx=0; idx < ${#log_file_lists[@]}; idx++))
	{
		 echo > $TARGET/${log_file_lists[$idx]}
		 cp /dev/null $TARGET/${log_file_lists[$idx]}	# 로그 파일의 크기를 0으로 설정함.
	}
}

function delete_and_clear_base_directory_logs()
{
	delete_log_files_incldue_date
	clear_log_files
	echo -e "$TARGET 로그 초기화 완료"

	TARGET=/var/log	# 초기화 	
	IS_SUB_DIR=0 	# 초기화 (기본 경로를 /var/log로 설정함)
}



# /var/log에 위치한 서브 디렉토리의 로그를 초기화한다.
function delete_and_clear_sub_directory_logs()
{
	IS_SUB_DIR=1
	VAR_LOG_SUB_DIR_NAME_LISTS=var_log_sub_dir_name_list.txt

	find $BASE_TARGET/* -type d > $VAR_LOG_SUB_DIR_NAME_LISTS

	readarray -t var_log_sub_dir_name_lists < $VAR_LOG_SUB_DIR_NAME_LISTS

	for ((index=0; index < ${#var_log_sub_dir_name_lists[@]}; index++)) #/var/log의 서브 디렉토리 경로 획득
	{
		TARGET=${var_log_sub_dir_name_lists[$index]}
			delete_log_files_incldue_date
			clear_log_files
		echo -e "|___________ $TARGET 로그 초기화 완료"

	}
		
	TARGET=/var/log	# 초기화 	
	IS_SUB_DIR=0 	# 초기화 (기본 경로를 /var/log로 설정함)
}

function delete_temp_files()
{
	rm -rf $DAILY_LOG_NAME_LISTS
	rm -rf $LOG_FILE_LISTS
	rm -rf $VAR_LOG_SUB_DIR_NAME_LISTS
}


delete_and_clear_base_directory_logs
delete_and_clear_sub_directory_logs
delete_temp_files
