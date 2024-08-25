#! /bin/bash
#
# #########################################################
# pre-commit hook to ensure updated svg files, mostly PlantUML
######
###########################################################

echo “pre-commit check”

# For each staged file
for file in $staged_files
do
  if [[ $file == *.puml ]]
  then 
    echo "# Updating svg for <${file}> ..."
    # Execute your script here. Replace 'your-script' with your actual script.
    java -jar tools/plantuml.jar $file -tsvg
    echo $file | sed -e 's/\.puml/.svg/g' | xargs git stage
    # If the script fails, abort the commit
  fi
  if [ $? -ne 0 ]; then
    trap error EXIT
    exit 1
  fi
done