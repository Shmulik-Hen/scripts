#!/bin/bash

# get all files in git repo
git ls-files > /tmp/git_files.txt 2>&1
#git st | awk -F: '/new file/ {print $2}' | sed -e 's/^ *//' | grep -v "^\.vscode" > /tmp/git_files.txt 2>&1

# check file types
echo -n > /tmp/git_file_types.txt
echo -n > /tmp/git_errors.txt
while IFS= read -r line; do
	type=$(file -b "$line")
	echo $type: \"$line\" >> /tmp/git_file_types.txt 2>>/tmp/git_errors.txt
done < /tmp/git_files.txt

# filter out text files
sed -i -e '/^.*ASCII text.*$/d' /tmp/git_file_types.txt
sed -i -e '/^.*Unicode text.*$/d' /tmp/git_file_types.txt
sed -i -e '/^empty.*$/d' /tmp/git_file_types.txt
sed -i -e '/^iCalendar.*$/d' /tmp/git_file_types.txt
sed -i -e '/^JSON.*$/d' /tmp/git_file_types.txt
sed -i -e '/^magic text.*.pyi\"$/d' /tmp/git_file_types.txt
sed -i -e '/^SVG Scalable Vector Graphics.*$/d' /tmp/git_file_types.txt

# sort the remaining binary files
sort /tmp/git_file_types.txt > /tmp/git_binaries_sorted.txt
awk -F: '{print $2}' /tmp/git_binaries_sorted.txt | sed -e 's/\"//g'> /tmp/git_binaries_only.txt

echo -n > /tmp/git_rm_output.txt
echo -n > /tmp/git_rm_errors.txt

# remove binary files from git
while IFS= read -r line; do
	git rm -f --cached --ignore-unmatch $line >> /tmp/git_rm_output.txt 2>>/tmp/git_rm_errors.txt
done < /tmp/git_binaries_only.txt
echo "Git cleanup completed. Check /tmp/git_rm_output.txt and /tmp/git_rm_errors.txt for details."
# Optionally, you can also add these files to .gitignore
# while IFS= read -r line; do
# 	echo "**/$(basename "$line")" >> .gitignore
# done < /tmp/git_binaries_only.txt
