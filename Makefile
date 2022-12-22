%.ipynb : %.jl
		jupytext  --to notebook $< --set-kernel julia-1.8

all: 01-DIVAnd-data-preparation.ipynb  02-DIVAnd-example-analysis-azores.ipynb
