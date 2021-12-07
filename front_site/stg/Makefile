init:
	terraform init
plan:
	terraform plan
apply:
	terraform apply
apply_refresh:
	terraform apply -refresh-only
import:
	terraform import $(ARG)
state_ls:
	terraform state list
state_show:
	terraform state show $(ARG)
state_rm:
	terraform state rm $(ARG)
fmt:
	terraform fmt -recursive -diff ../modules
mfmt: 
	terraform fmt -diff
importer:
# e.g.) make importer ARG='alb,ec2_instance,eip,ebs,igw,rds,route_table,sg,subnet,vpc,vpc_peering'
	terraformer import aws --resources=$(ARG) --connect=true --regions=ap-northeast-1 --profile=nice_service_name
