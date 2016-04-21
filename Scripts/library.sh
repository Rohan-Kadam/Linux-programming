#!/bin/bash

#usage: is_hex A2
is_hex(){
    # set regular expresion'
    local reg_exp='^[0-9A-Fa-f]+$'

    # =~ means 'match'
    if [[ $1 =~ $reg_exp ]] ; then
        return 0
    else
        return 1
    fi
}

#usage: is_decimal 123
is_decimal(){
    # set regular expresion'
    local reg_exp='^[0-9]+$'

    # =~ means 'match'
    if [[ $1 =~ $reg_exp ]] ; then
        return 0
    else
        return 1
    fi
}

#usage: find_pid $indoe
#success: return pid
#fail: return 0
find_pid(){
   
    local inode=$1 
    local pid_valid=0

    #find belong which process id
    local pid_list=`sudo ls /proc`
    for pid in $pid_list; do
        echo -ne "inode is $1,checking pid=$pid...\r"
        #check pid. it must be a number
        pid_valid=0
        is_decimal $pid
        if [ $? -eq 0 ] ; then
            pid_valid=1
        fi

        #if /proc/#pid file exist, then find out socket inode
        if [ "$pid_valid" == "1" ] && [ -e "/proc/$pid" ] ; then
            #echo "inode=$inode"
            is_inode_found $pid socket $inode
            if [ $? -eq 0 ] ; then
                return $pid
            fi
        fi
    done
   
    return 0
}

<<COMMENT
usage: is_inode_found $pid $fd_type $inode
return code:
0: found 
1: not found
COMMENT

is_inode_found(){
    
    local list=`sudo ls /proc/$1/fd -al | grep $2`
    while read line; do 
        #echo "LINE: $line";
        local inode=`echo $line | cut -d " " -f 10 | cut -d "[" -f 2 | cut -d "]" -f 1`
        #echo "inode: $inode"
        if [ "$inode" == "$3" ] ; then
            return 0 #inode is found
        fi
    done <<< "$list"
    
    return 1 #inode not found
}

show_result(){

    if [ $1 -eq 0 ] ; then
        echo "function return SUCESS."
    else
        echo "function return FAIL"
    fi
}

#pid=1408
#fd_type=socket
#inode=8092
#is_inode_found $pid $fd_type $inode

#echo "is_match ret=$?"
#find_pid $inode
#if [ "$?" != "0" ] ; then
#    echo "xxxxxxxxxxxxxxx===> find out inode 8092:pid=$pid"
#fi

