cd Report
pdflatex -interaction nonstopmode main.tex 2>&1 > /dev/null
rm main.log
rm main.aux
mv main.pdf Report.pdf
cd ..
