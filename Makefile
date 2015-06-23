region=us-west-2

.PHONEY: all

all:
	

plan: build/all_plan
	terraform plan

.PHONEY: build/all_plan

build/all_plan: build/coreos_alpha_ami_id

build/coreos_alpha_ami_id: | build
	curl -sk https://alpha.release.core-os.net/amd64-usr/current/coreos_production_ami_all.json | jq -r ".amis | map(select(\"$(region)\" == .name))[0].hvm" > build/coreos_alpha_ami_id

build:
	mkdir -p build

clean:
	rm -rf build
