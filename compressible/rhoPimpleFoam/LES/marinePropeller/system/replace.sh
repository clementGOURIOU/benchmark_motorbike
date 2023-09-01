

CWD=$PWD

FILE_LIST=`ls -ltr| grep processor | awk '{print $NF}'`
#echo $FILE_LIST

for dirName in $FILE_LIST;
do
 cd "$dirName"
 mv 5000 5000_steadyState
 rm -rf 0
 ln -s 5000_steadyState 0
 cd $CWD
 echo "Done $dirName"
done
