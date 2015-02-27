curl http://wiki.openstreetmap.org/wiki/FR:Cantons_in_France > wiki_osm_cantons.html

cat wiki_osm_cantons.html | grep JORFTEXT[0-9]* -o | grep -v JORFTEXT000028749547 > id_jorf.csv

for d in `cat id_jorf.csv` ; do \
  curl -s http://www.legifrance.gouv.fr/affichTexte.do?cidTexte=$d | grep "Le canton n°.*\." -o > $d.txt ; done

for f in JORF*.txt ; do \
 cat $f | sed 's!Le canton n° \([0-9]*\) \(.*\) comprend.*Le bureau centralisateur.*commune \(.*\)\.!\1;\2;\3!g' \
 | tr -d '()' | sed 's/;de /;/g' | sed 's/;d./;/g' | sed 's/;du /;Le /g' > $f.csv ; done


echo "jorf;dept;canton;nom;bureau" > cantons.csv
for c in `cat dept_jorf.csv`; do d=`echo $c|sed 's/,.*//'`;j=`echo $c|sed 's/.*,//'`; \
  cat $j.txt | sed 's!Le canton n° \([0-9]*\) \(.*\) comprend.*Le bureau.*centralisateur.*commune \(.*\)\.!\1;\2;\3!g' \
   | tr -d '()' | sed 's/;de /;/g' | sed 's/;d./;/g' | sed 's/;du /;Le /g' | sed "s/\(^.*\)/$j;$d;\1/g" >> cantons.csv ; done


echo "jorf;dept;canton;nom" > cantons_complexes.csv
for c in `cat dept_jorf.csv`; do d=`echo $c|sed 's/,.*//'`;j=`echo $c|sed 's/.*,//'`; \
  cat $j.txt | egrep 'Le canton n° [0-9]* \(.*[0-9]\) comprend' | sed 's!Le canton n° \([0-9]*\) \(.*\) comprend.*Le bureau.*centralisateur.*commune \(.*\)\.!\1;\2!g' \
   | tr -d '()' | sed 's/;de /;/g' | sed 's/;d./;/g' | sed 's/;du /;Le /g' | sed "s/\(^.*\)/$j;$d;\1/g" >> cantons_complexes.csv ; done

for c in `cat cantons_complexes.csv`; do echo $c | awk -f cantons_complexes.awk ; echo $jorf ; done

