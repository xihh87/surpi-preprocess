<preprocess.mk

PREPROCESS_ALL=`{find -L data/ -name '*.fastq' -o -name '*.fastq.gz' \
	| sed -e 's#^data/#results/preprocess/#g' \
	 -e 's#\.fastq\(\.gz\)\?$#.uniq.cropped.dusted.fastq#g' }
PREPROCESS_UNIQ=`{find -L data/ -name '*.fastq' -o -name '*.fastq.gz' \
	| sed -e 's#^data/#results/preprocess/#g' \
	 -e 's#\.fastq\(\.gz\)\?$#.uniq.dusted.fastq#g' }
PREPROCESS_CROP=`{find -L data/ -name '*.fastq' -o -name '*.fastq.gz' \
	| sed -e 's#^data/#results/preprocess/#g' \
	 -e 's#\.fastq\(\.gz\)\?$#.cropped.dusted.fastq#g' }

preprocess:V: $PREPROCESS_ALL
uniq:V: $PREPROCESS_UNIQ
crop:V: $PREPROCESS_CROP

data/%.fastq:	data/%.fastq.gz
	gzip -d -c $prereq > $target

results/preprocess/%.uniq.fastq:	data/%.fastq
	mkdir -p `dirname $target`
	fastq \
		filter \
		--unique \
		--adjust $PREPROCESS_QUALBASE \
		$prereq \
		> $target

results/preprocess/%.uniq.cropped.fastq:	results/preprocess/%.uniq.fastq
	mkdir -p `dirname $target`
	# This cropping is recommended by the SURPI pipeline
	awk '(NR%2==1){print $0} (NR%2==0){print substr($0, 10, 75)}' \
		$prereq \
		> $target

results/preprocess/%.cropped.fastq:	data/%.fastq
	mkdir -p `dirname $target`
	# This cropping is recommended by the SURPI pipeline
	awk '(NR%2==1){print $0} (NR%2==0){print substr($0, 10, 75)}' \
		$prereq \
		> $target

results/preprocess/%.dusted.fastq	\
results/preprocess/%.dusted.bad.fastq	\
results/preprocess/%.prinseq-stats:	results/preprocess/%.fastq
	mkdir -p `dirname $target`
	FASTQ=3
	prinseq-lite.pl \
		-fastq $prereq \
		-out_format $FASTQ \
		-log results/preprocess/$stem.log \
		-out_good results/preprocess/$stem.dusted \
		-out_bad  results/preprocess/$stem.dusted.bad \
		-lc_method dust \
		-lc_threshold 7
