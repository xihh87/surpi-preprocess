<preprocess.mk

PREPROCESS_ALL=`{find -L data/ -name '*.fastq*' | sed -e 's#^data/#results/preprocess/#g' -e 's#$##.uniq.cropped.dusted' }
PREPROCESS_UNIQ=`{find -L data/ -name '*.fastq*' | sed -e 's#^data/#results/preprocess/#g' -e 's#$##.uniq.dusted' }
PREPROCESS_CROP=`{find -L data/ -name '*.fastq*' | sed -e 's#^data/#results/preprocess/#g' -e 's#$##.cropped.dusted' }

preprocess:V: $PREPROCESS_ALL
uniq:V: $PREPROCESS_UNIQ
crop:V: $PREPROCESS_CROP

results/preprocess/%.uniq:	data/%
	fastq \
		filter \
		--unique \
		--adjust $PREPROCESS_QUALBASE \
		$prereq \
		> $target

results/preprocess/%.cropped:	results/preprocess/%.uniq
	# This cropping is recommended by the SURPI pipeline
	awk '(NR%2==1){print $0} (NR%2==0){print substr($0, 10, 75)}' \
		$prereq \
		> $target

results/preprocess/%.cropped:	data/%
	# This cropping is recommended by the SURPI pipeline
	awk '(NR%2==1){print $0} (NR%2==0){print substr($0, 10, 75)}' \
		$prereq \
		> $target

results/preprocess/%.dusted	results/preprocess/%.dusted.bad:	results/preprocess/%
	FASTQ=3
	prinseq-lite.pl \
		-fastq $prereq \
		-out_format $FASTQ \
		-out_good results/preprocess/$stem.dusted \
		-out_bad  results/preprocess/$stem.dusted.bad \
		-lc_method dust \
		-lc_threshold 7
