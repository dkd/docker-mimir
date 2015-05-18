GGWSREVISION=23111

all: run

ggws:
	if [ -d "GGWS" ]; then \
	 	cd GGWS; \
		svn up -r$(GGWSREVISION); \
		cd ..; \
	 else \
		svn checkout -r $(GGWSREVISION) svn+ssh://gateservice2.dcs.shef.ac.uk/data/svn/gate-extras-svnrep/trunk/gate-wasp GGWS; \
	 fi

build: ggws
	if [ `boot2docker status` != "running" ] ; then \
	 	boot2docker up; \
	 fi
	 docker build -t "dkd:gate" .

run: build
	docker run -p "8080:8080" "dkd:gate"

interactive: build
	docker run -p "8080:8080" -it "dkd:gate" /bin/bash -c "bash -c \"catalina.sh run &\"; bash --login"

nontom:
	docker run -p "8080:8080" -it "dkd:gate" /bin/bash
