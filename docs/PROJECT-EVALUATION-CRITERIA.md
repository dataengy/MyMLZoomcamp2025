Please evaluate the submission according to the following criteria.
1. Problem description

Problem is not described (0 points)

Problem is described in README briefly without much details (1 point)

Problem is described in README with enough context, so it's clear what the problem is and how the solution will be used (2 points)
2. EDA

No EDA (0 points)

Basic EDA (looking at min-max values, checking for missing values) (1 point)

Extensive EDA (ranges of values, missing values, analysis of target variable, feature importance analysis). For images: analyzing the content of the images. For texts: frequent words, word clouds, etc. (2 points)
3. Model training

No model training (0 points)

Trained only one model, no parameter tuning (1 point)

Trained multiple models (linear and tree-based). For neural networks: tried multiple variations - with dropout or without, with extra inner layers or without (2 points)

Trained multiple models and tuned their parameters. For neural networks: same as previous, but also with tuning: adjusting learning rate, dropout rate, size of the inner layer, etc. (3 points)
4. Exporting notebook to script

No script for training a model (0 points)

The logic for training the model is exported to a separate script (1 point)
5. Reproducibility

Not possible to execute the notebook and the training script. Data is missing or it's not easily accessible (0 points)

It's possible to re-execute the notebook and the training script without errors. The dataset is committed in the project repository or there are clear instructions on how to download the data(1 point)
6. Model deployment

Model is not deployed (0 points)

Model is deployed (with Flask, BentoML or a similar framework) (1 point)
7. Dependency and environment management

No dependency management (0 points)

Provided a file with dependencies (requirements.txt, pipfile, bentofile.yaml with dependencies, etc.) (1 point)

Provided a file with dependencies and used virtual environment. README says how to install the dependencies and how to activate the env(2 points)
8. Containerization

No containerization (0 points)

Dockerfile is provided or a tool that creates a docker image is used (e.g. BentoML) (1 point)

The application is containerized and the README describes how to build a container and how to run it (2 points)
9. Cloud deployment

No deployment to the cloud (0 points)

Docs describe clearly (with code) how to deploy the service to cloud or Kubernetes cluster (local or remote) (1 point)

There's code for deployment to cloud or Kubernetes cluster (local or remote). There's a URL for testing - or video/screenshot of testing it (2 points)
