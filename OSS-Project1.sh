#!/bin/bash

if [ ${#} -ne 3 ]; then
    echo "Usage: ${0} file1 file2 file3"
    exit 1
fi

team_csv_path=${1}
player_csv_path=${2}
match_csv_path=${3}

printMenu() {
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Apprearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in mateches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"
    echo -n "Enter your CHOICE (1~7) : "
}

menu1() {
    echo -n "Do you want to get the Heung-Min Son's data? (y/n) : "
    read choice
    if [ "${choice}" == "y" ]; then
        while IFS="," read full_name age position current_club nationality appearances_overall goals_overall assists_overall
        do
            if [ "${full_name}" == "Heung-Min Son" ]; then
                echo "Team: ${current_club}, Appearance: ${appearances_overall}, Goal: ${goals_overall}, Assist: ${assists_overall}"
            fi
        done < <(tail -n +2 ${player_csv_path})
    fi
    echo ""
    
}

menu2() {
    echo -n "What do you want to get the team data of league_position[1~20] : "
    read  target_league_position
    while IFS="," read common_name wins draw losses points_per_game league_position cards_total shots fouls
    do
        if [ ${league_position} -eq ${target_league_position} ]; then
            score=$(echo "${wins}; ${draw}; ${losses}" |awk '{printf "%f", $1/($1+$2+$3)}')
            echo "${league_position} ${common_name} ${score}"
        fi
    done < <(tail -n +2 ${team_csv_path})
    echo ""
}

menu3() {
    read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) : " choice
    count=0
    if [ "${choice}" == "y" ]; then
        echo "*** Top-3 Attendance Match ***"
        echo ""
        while IFS="," read data_gmt attendance home_team_name away_team_name home_team_goal_count away_team_goal_count stadium_name
        do
            echo "${home_team_name} vs ${away_team_name} (${data_gmt})"
            echo "${attendance} ${stadium_name}"
            echo ""
        done < <(tail -n +2 ${match_csv_path} | sort -t ',' -rnk 2 | head -n 3)
    fi
    echo ""
}

menu4() {
    read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " choice
    if [ "${choice}" == "y" ]; then
        while IFS="," read common_name wins draw losses points_per_game league_position cards_total shots fouls
        do
            echo "${league_position} ${common_name}"
            h_goal=0
            h_appearance=0
            while IFS="," read full_name age position current_club nationality appearances_overall goals_overall assists_overall
            do
                if [ ${h_goal} -lt ${goals_overall} ] || [[ ${h_goal} == ${goals_overall} && ${h_appearance} -gt ${appearances_overall} ]]; then
                    h_goal=${goals_overall}
                    h_appearance=${appearances_overall}
                    h_full_name=${full_name}
                fi
            done < <(cat ${player_csv_path} | grep -a ",${common_name},")
            echo "${h_full_name} ${h_goal}"
            echo ""
        done < <(tail -n +2 ${team_csv_path} | sort -t ',' -nk 6)
    fi
    echo ""
}

menu5() {
    read -p "Do you want to modify the format of date? (y/n) : " choice
    if [ "${choice}" == "y" ]; then
        while read date
        do
            modified_data=$(date +"%Y/%m/%d %l:%M%P" -d "$(echo ${date} | sed "s/ - / /")") 
            echo "${modified_data}"
        done < <(cut -d "," -f1 ${match_csv_path} | tail -n +2 | head -n 10)
    fi
    echo ""
}

menu6() {
    declare -a team_list
    count=1
    while read common_name
    do
        echo "${count}) ${common_name}"
        team_list[${count}]=${common_name}
        count=$(expr $count + 1)
    done < <(cut -d "," -f1 ${team_csv_path} | tail -n +2)
    read -p "Enter your team number : " team_choice
    team_name=${team_list[${team_choice}]}
    echo ""

    largest_score=0
    while IFS="," read date_gmt attendance home_team_name away_team_name home_team_goal_count away_team_goal_count stadium_name
    do
        if [ "${home_team_name}" == "${team_name}" ]; then
            score_diff=$(expr ${home_team_goal_count} - ${away_team_goal_count})
            if [ ${largest_score} -lt ${score_diff} ]; then
                largest_score=${score_diff}
            fi
        fi
    done < <(tail -n +2 ${match_csv_path})
    while IFS="," read date_gmt attendance home_team_name away_team_name home_team_goal_count away_team_goal_count stadium_name
    do
        if [ "${home_team_name}" == "${team_name}" ]; then
            score_diff=$(expr ${home_team_goal_count} - ${away_team_goal_count})
            if [ ${score_diff} -eq ${largest_score} ]; then
                echo "${date_gmt}"
                echo "${home_team_name} ${home_team_goal_count} vs ${away_team_name} ${away_team_goal_count}"
                echo ""
            fi
        fi
    done < <(tail -n +2 ${match_csv_path})
}

menu7 () {
    echo "Bye!"
    exit
}

echo "**********OSS1 - Project1**********"
echo "*      StudentID : 12184101      *"
echo "*      Name : Dongchan Kim       *"
echo ""

while :
do
    printMenu
    read choice
    case ${choice} in
        "1") menu1
            ;;
        "2") menu2 
            ;;
        "3") menu3 
            ;;
        "4") menu4
            ;;
        "5") menu5
            ;;
        "6") menu6
            ;;
        "7") menu7
            ;;
    esac
done
