.PHONY: test

test:
	@set -e; for spec in tests/*_spec.lua; do \
		echo "== $$spec"; \
		nvim --headless -l "$$spec"; \
	done; \
	echo "All specs passed"
