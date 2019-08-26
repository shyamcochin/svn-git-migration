#!/bin/bash
#git migration
url="http://192.168.100.7/code/"
#change code to art if repo is art
repolist="repolist.txt"
#giturl="git@192.168.100.6:r7repo/code/content/projects"

#change systest to the desired group
flag=1
#General Function
git_migrate()
{
#svn folder
#mkdir $reponame;cd $reponame
#echo "Checking out Revision" $rev
#svn checkout repo
if [ $i -eq 1 ];then
	#echo "First Revision"
	mkdir $reponame;cd $reponame
	echo "Checking out revision" $rev
	svn co --username="syam" --password="password" --non-interactive $url$reponame/trunk --ignore-externals -r $rev .
	echo ".svn" > .gitignore
	git init
	git remote add origin $giturl/$reponame.git
fi
#if [ $i -gt 1 ];then
#	cd $reponame
#fi
svn up -r $rev --ignore-externals
git add -A
git commit -m "1st Commit by Admin"
git push -u $giturl/$reponame.git master
if [ $rev != "HEAD" ]
then
	git tag -a "V"$rev -m "Tagging Revision"$rev
	git commit -m "TaggingRevision"$rev
	git push $giturl/$reponame.git "V"$rev
fi
}


#Program
while read line 
do
	#echo "Repo Name:" $line
	declare -a revlist
	revlist=($line)
	reponame=${revlist[0]}
	echo "Reponame" $reponame

	i=1
#	echo "Orginal value of flag" $flag	
	for (( flag=1; $flag != 0; i=$((i+1)) ))
	do
#		echo "Flag Value" $flag
#		echo "Original Value of i" $i
		if [[ ${revlist[$i]} == "HEAD" ]] || [[ ${revlist[$i]} == "" ]]
		then
			flag=0
			echo "Flag value changed in HEAD check" $flag
			rev="HEAD"
		else
			echo "Revision Number" ${revlist[$i]}
			rev=${revlist[$i]}
		fi
		git_migrate
		#i=$((i+1))
		#echo "Newvalue of i" $i
		if [ $i -gt 8 ]
		then
			echo "Revision is more than 8"
			flag=0
#			echo "Flag valu inside loop" $flag
	#		continue
		fi
	sleep 5
	done
cd ..
sleep 5
rm -rf $reponame
done < "$repolist"

