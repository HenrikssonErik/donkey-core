parsers-version=master
analyzer-version=master
modeler-version=master

THEIAATTACK = data/theia-e3/attack/edgelists_attack
THEIABENIGN = data/theia-e3/benign/edgelists_benign

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
	wget --retry-connrefused --waitretry=5 --read-timeout=30 --tries=50 --no-dns-cache https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:$(1) -O $(2)/tmp.tar.gz
	cd $(2) && tar -xzf tmp.tar.gz
	rm -f $(2)/tmp.tar.gz
endef

define dataverse_download_file
	wget --retry-connrefused --waitretry=5 --read-timeout=30 --tries=50 --no-dns-cache https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:$(1) -O $(2)
endef

define dataverse_download_zip
	wget --retry-connrefused --waitretry=5 --read-timeout=30 --tries=50 --no-dns-cache https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:$(1) -O $(2)/tmp.zip
	cd $(2) && unzip -o tmp.zip
	rm -f $(2)/tmp.zip
endef

download_streamspot:
	mkdir -p data
	$(call dataverse_download, 10.7910/DVN/83KYJY/JVJXX5, data/)

download_darpa_cadets:
	mkdir -p data/cadets-e3
	$(call dataverse_download,10.7910/DVN/MPUCQU/BHQBB9, data/cadets-e3/) 
	$(call dataverse_download,10.7910/DVN/MPUCQU/GAMHTP, data/cadets-e3/)

download_darpa_theia:
	mkdir -p ../../data/theia-e3/attack/edgelists_attack
	mkdir -p ../../data/theia-e3/attack/edgelists_benign
	#Theia CDM Benign Dataset (E3)
	$(call dataverse_download,10.7910/DVN/QTTIZN/MCNB7N,$(THEIABENIGN))
	# Edgelist for Theia E3 5m
	$(call dataverse_download_file,10.7910/DVN/L8LROS/EDDKIA,$(THEIAATTACK)/theia-e3-5m.txt)	
	$(call dataverse_download,10.7910/DVN/L8LROS/EDB6IX,$(THEIAATTACK))
	# Edgelist for Theia Engagement 3 3
	$(call dataverse_download_file,10.7910/DVN/65W3C3/TQE9HY,$(THEIAATTACK)/theia-e3-3.txt) 
	$(call dataverse_download,10.7910/DVN/65W3C3/MLXYED,$(THEIAATTACK)) 
	# Edgelist for Theia Engagaement 3 1r
	$(call dataverse_download,10.7910/DVN/BXBZSQ/OJSK1R,$(THEIAATTACK))
	$(call dataverse_download,10.7910/DVN/BXBZSQ/KM0J4X,$(THEIAATTACK))
	# Edgelist for Theia Engagement 3 6r
	$(call dataverse_download,10.7910/DVN/KN2RDY/A7FQXI,$(THEIAATTACK))

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
