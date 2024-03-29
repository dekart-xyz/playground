# load .env
# https://lithic.tech/blog/2020-05/makefile-dot-env
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

db-instance:
	gcloud sql instances create ${DB_INSTANCE_NAME} \
		--database-version=POSTGRES_12 \
		--tier=db-f1-micro\
		--region=europe-west1

db-database:
	gcloud sql databases create dekart --instance=${DB_INSTANCE_NAME}


db-password:
	gcloud sql users set-password postgres --instance=${DB_INSTANCE_NAME} --password=dekart

storage:
	gsutil mb -b on -l europe-west1 gs://${BUCKET}/

app-create:
	gcloud app create --region=europe-west

.PHONY: app.yaml
app.yaml:
	BUCKET=${BUCKET} \
	PROJECT_ID=${PROJECT_ID} \
	MAPBOX_TOKEN=${MAPBOX_TOKEN} \
	DEKART_IAP_JWT_AUD=${DEKART_IAP_JWT_AUD} \
	envsubst < app.example.yaml > app.yaml

app-deploy:	app.yaml
	gcloud app deploy app.yaml --project=${PROJECT_ID}

all: db-instance db-database db-password storage app-create app-deploy