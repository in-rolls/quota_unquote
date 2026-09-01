.PHONY: sync data lint test paper check

sync:
	Rscript -e 'renv::restore(prompt = FALSE)'
	uv sync --all-groups

data:
	Rscript scripts/99_run_all.R

lint:
	Rscript -e 'l <- lintr::lint_dir("scripts"); print(l); quit(status = as.integer(length(l) > 0L))'
	.venv/bin/ruff check .
	.venv/bin/ruff format --check .

test:
	Rscript tests/testthat.R
	.venv/bin/pytest -q

paper:
	cd ms && ./compile.sh

check: lint test paper
