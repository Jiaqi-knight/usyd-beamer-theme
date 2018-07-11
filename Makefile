makedir = output

examples = $(wildcard examples/*.tex)

all: $(examples:.tex=.pdf)

tex_flags = -silent -interaction=batchmode

DOCKER_CMD = docker run -ti -v packages:/miktex/.miktex -v $(CURDIR):/miktex/work miktex/miktex

%.pdf: %.tex | packages output
ifndef TRAVIS
	latexmk ${tex_flags} -outdir=${makedir} -pdf $<
else
	${DOCKER_CMD} latexmk ${tex_flags} -outdir=${makedir} -pdf $<
endif
	cp ${makedir}/$(notdir $@) .

setup: | packages
	${DOCKER_CMD} mpm --update-db
	${DOCKER_CMD} mpm --update latexmk || ${DOCKER_CMD} mpm --install latexmk


packages output:
	mkdir -p $@
	chmod a+rw $@

clean:
	rm -rf ${makedir}/*
	rm -f $(examples:.tex=.pdf)

