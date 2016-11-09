<dust.mk

DUST_TARGETS=`{./targets_dust}

dust:V: $DUST_TARGETS

data/%.fastq:	data/%.fastq.gz
	gzip -d -c $prereq > $target

results/dust/%.log	\
results/dust/%_1.fastq	\
results/dust/%_2.fastq	\
results/dust/%_1_singletons.fastq	\
results/dust/%_2_singletons.fastq	\
results/dust_bad/%_1.fastq	\
results/dust_bad/%_2.fastq	\
results/dust_bad/%_1_singletons.fastq	\
results/dust_bad/%_2_singletons.fastq	\
:	data/%_R1.fastq	data/%_R2.fastq
	mkdir -p results/dust/`dirname $stem`
	mkdir -p results/dust_bad/`dirname $stem`
	FASTQ=3
	prinseq-lite.pl \
		-fastq data/"$stem"_R1.fastq \
		-fastq2 data/"$stem"_R2.fastq \
		-out_format $FASTQ \
		-log results/dust/$stem.log \
		-out_good results/dust/$stem \
		-out_bad  results/dust_bad/$stem \
		-lc_method dust \
		-lc_threshold 7 \
	&& touch $target

clean_dust:V:
	rm -r results/dust results/dust_bad
