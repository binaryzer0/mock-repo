# Building and open-source IPS/IDS Service on Gateway Load Balancer
This repository has deployment, installation and clean up instructions on how to deploy and manage Suricata in AWS with Elastic Container Services and Gateway Loadbalancer. The main use-case for this repo is to provide a baseline from which you can build on. The solution will deploy Suricata on ECS and provides an opportunity to adjust the Suricata configuration and rulesets using a GitOps workflow.

<img width="100" height="160" style="float: right;" src="img/meerkat.jpg">

## How to deploy

### Quickstart
The quickest way to deploy Suricata and the CI/CD pipeline needed to support a GitOps workflow is to run a quickstart Cloudformation template. The Quickstart template will setup a AWS Codepipeline using AWS CodeCommit, AWS CodeBuild and CloudFormation and various support resources such as SSM Parameters.
The Quickstart template will copy this GitHub Repo into AWS CodeCommit which will be the Git repo you work against. 

We provide two different QuickStarts:

1. /deployment/base-create-vpc.yaml is creating a complete new environment with a VPC where Suricata will be deployed.
2. /deployment/base-existing-vpc.yaml is using an already existing VPC where Suricata will be deployed. The existing VPC will need to have three private subnets with a default route to a Nat Gateway. The Nat Gateway will of course need to be within a subnet that has the ability to reach the internet via an Internet Gateway.

![Solution Overview](img/suricata-docker-Suricata-cluster.png)
##### In the following scenario we will use /deployment/base-create-vpc.yaml.

1. Create a Cloudformation stack using the Cloudformation template /deployment/base-create-vpc.yaml in your account.
2. After the stack is created, go to AWS CodeCommit where you will see a repository which looks identical to this repository. Nothing has been built yet, so if you want you can now make changes to the Suricata config, Rulesets, Cloudformation Parameters etc.
3. Go to CodePipeline and select "Enable transition". The pipeline will now start to build a docker image and after that deploy your suricata cluster using Cloudformation.
4. For quick testing: Create a Cloudformation stack using https://github.com/aws-samples/aws-gateway-load-balancer-code-samples/blob/main/aws-cloudformation/distributed_architecture/DistributedArchitectureSpokeVpc2Az.yaml and use the Cloudformation output of `ApplianceVpcEndpointServiceName` from the suricata cluster cloudforamtion stack as the input to the `ServiceName` parameter.


##### Ruleset Management

This solution provides three levels of Ruleset management. 

* This first is via the 'cluster-template-configuration.json' file. In here you can specify additional rulesets to be downloaded by the Suricata engine, periodically ( 60 seconds by default ) and loaded into the engine. The rulset definitions are baked into the image.....

```
    {
        "Parameters" : {
            "PcapLogRententionS3": "5",
            "DefaultLogRententionCloudWatch": "3",
            "EveLogRententionCloudWatch": "30",
            "SuricataRulesets": "",
            "SuricataInstanceType": "t3.large"
        }
    }
```

* The second location for rule entry is within the /Dockerfiles/suricata/static.rules file. This rule file does not update dynamically and is tied to the latest commit in the repo ( think about using this for rules that shall always be enforced and should not be removed! )

* The third location is within the /dynamic.rules file within the code repo base directory. When rules are specified here they are baked into the image as part of the image creation process by CodeBuild. However this is not the intention for this rule file. It is intended that an operator will update the rules file in an S3 bucket as part of the operational changes to the IPS service and the same update process that downloads third party updates will read the S3 file contents periodically ( 60 seconds by default ) and load them into the dynamic.rules file and the Suricata engine.

### Manual deployment / Using existing CI/CD pipeline
If you already have an existing CI/CD pipeline, a Git repository or similar that you want to use instead, this is also possible.

You can find the CloudFormation template which is deploying the Suricata cluster in: /deployment/suricata/ and the various steps to build the Container image in /Dockerfiles/*/buildspec.yml.

You need to build the suricata Dockerfiles and provide the built Suricata Container image together with an existing VPC which need to have three private subnets with a default route to NAT to the Cloudforamtion suricata cluster template.

## How to cleanup

### Pipeline Deployed Artefact

The pipeline deploys a child stack from the code in the CodeCommit repository. To remove this, you can simply delete the stack that the pipeline created. You may need to empty S3 buckets of content before you do this!

### Pipeline Base Stack

The pipeline stack was deployed from a initiation template ( this is also present in the code in the CodeCommit repository ). To remove this, you can simply delete the stack that defined the pipeline. You may need to empty S3 buckets of content before you do this!
## Commmon questions:

**How can I add my own rules?**
In the current setup, you need to build your rules into the docker image. Add your rules to: Dockerfiles/suricata/var/lib/rules/my.rules and rebuild, upload and deploy your new docker image. The thought here is to keep your rules versionized together with the suricata config and suricata version.

**How can I make changes to the suricata config?**
In the current setup, you need to make changes in the suricata.yaml in Dockerfiles/suricata/etc/suricata/suricata.yaml and rebuild, upload and deploy your new docker image. The thought here is to keep your config versioned together with the your rules and suricata version.

**What logs are automatically ingested to CloudWatch Logs / S3?**
In the default suricata configuration provided in this repo, suricata will use the following logging modules: fast.log, eve-log.json and pcap. These logs are tailed and rotated automatically.

* fast.log is ingested into CloudWatch Logs: /suricata/fast/ and is  saved for 3 days (Configured in /deployment/suricata/cluster-template-configuration.json)
* eve-log.json is ingested into CloudWatch Logs: /suricata/eve/ and is saved for 30 days (Configured in /deployment/suricata/cluster-template-configuration.json)
* pcap is ingested into a S3 bucket created by the Suricata Cluster Configuration stack and is saved for 30 days (Configured in /deployment/suricata/cluster-template-configuration.json).

You can disable these logs or enable other logs by editing the suricata config: /Dockerfiles/suricata/etc/suricata/suricata.yml

### Roadmap / TODO / Ideas:


* Create a template which dont deploy a full VPC, so customers can create the Suricata ECS cluster in an existing architecture.
* Move Logrotation, CloudWatch agent to sidecar containers from EC2 configuration
* Graviton / ARM support
* Clean the CFN template(s), eg adding tags, Metadata, see over naming conventions.
* Enable "Deployment circuit breaker" so ECS can automatically rollback bad deployments.
* Create sample CFN templates that creates some example CW alerts, dashboards etc that uses the ingested logs.