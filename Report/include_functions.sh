cd ../Functions
ls . | grep '\.sql$' |awk '{print "\\lstinputlisting[language=sql]{../Functions/"$1"}"}'
for d in *; do
  if [ -d "$d" ]; then        
     cd "$d"
     ls . | grep '\.sql$' |awk -v d="$d" '{print "\\lstinputlisting[language=sql]{../Functions/"d"/"$1"}"}'
     cd ..
  fi
done
cd ../Report
