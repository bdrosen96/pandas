GCC_DOCKER_IMAGE = quay.io/pypa/manylinux1_x86_64
GCC_DOCKER_IMAGE_TAG = latest
SRC_DIR = /opt/drpandas

tseries: pandas/lib.pyx pandas/tslib.pyx pandas/hashtable.pyx
	python setup.py build_ext --inplace

.PHONY : develop build clean clean_pyc tseries doc

clean:
	-python setup.py clean

clean_pyc:
	-find . -name '*.py[co]' -exec rm {} \;

sparse: pandas/src/sparse.pyx
	python setup.py build_ext --inplace

build: clean_pyc
	python setup.py build_ext --inplace

develop: build
	-python setup.py develop

doc:
	-rm -rf doc/build doc/source/generated
	cd doc; \
	python make.py clean; \
	python make.py html

docker-build:
	docker run -e DATAROBOT_USER_ID=1001 -it --rm -v "$(PWD)":"$(SRC_DIR)" -w "$(SRC_DIR)" $(GCC_DOCKER_IMAGE):$(GCC_DOCKER_IMAGE_TAG) /bin/sh -c "export PATH=/opt/python/cp34-cp34m/bin:\$$PATH && pip install -U pip && pip install Cython && pip install -r requirements.txt && python setup.py bdist_wheel"

bdist-wheel:
	python setup.py bdist_wheel

docker-image-build:
	docker build -t $(GCC_DOCKER_IMAGE):$(GCC_DOCKER_IMAGE_TAG) .

test-wheel:
	mkdir .test ; cd .test ; pip install -r ../requirements.txt ; \
    pip install -U `ls ../dist/*.whl -t | head -1` ; \
    python -c "import pandas020 as pd; pd.test()"

