parsers-version=master
analyzer-version=master
modeler-version=master

prepare_parsers:
	mkdir -p build
	cd build && git clone --single-branch -b $(parsers-version) https://github.com/HenrikssonErik/donkey-parsers.git

prepare_analyzer:
	mkdir -p build
	cd build && git clone --single-branch -b $(analyzer-version) https://github.com/HenrikssonErik/donkey-analyzer.git
	cd build/donkey-analyzer && make sb

prepare_modeler:
	mkdir -p build
	cd build && git clone --single-branch -b $(modeler-version) https://github.com/HenrikssonErik/donkey-modeler.git

prepare_output:
	mkdir -p output

prepare: prepare_parsers prepare_analyzer prepare_modeler prepare_output

define dataverse_download
	wget --retry-connrefused --waitretry=5 --read-timeout=30 --tries=50 --no-dns-cache https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:$(1) -O data/tmp.tar.gz
	cd data && tar -xzf tmp.tar.gz
	rm -f data/tmp.tar.gz
endef

download_streamspot:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/83KYJY/JVJXX5)

download_darpa:
	mkdir -p data
	mkdir -p data/cadets-e3
	$(call dataverse_download,10.7910/DVN/MPUCQU/BHQBB9) 
	$(call dataverse_download,10.7910/DVN/MPUCQU/GAMHTP)
	mv data/attack data/cadets-e3/
	mv data/benign data/cadets-e3/
run_toy:
	cd build/donkey-parsers && make toy
	cd build/donkey-analyzer && make toy
	cd build/donkey-modeler && make toy

toy: prepare download_streamspot run_toy

run_complete_evasion_test:
	cd build/donkey-parsers && make evasion_mimicry
	cd build/donkey-analyzer && make train_mimicry && make evasion_mimicry && make attack_mimicry && make benign_mimicry
	cd build/donkey-modeler && make evasion_mimicry && make attack_mimicry && make benign_mimicry

clean:
	rm -rf build
	rm -rf data
