ls ../Generator | grep '\.py$' |awk '{print "\\lstinputlisting[language=python]{../Generator/"$1"}"}'
