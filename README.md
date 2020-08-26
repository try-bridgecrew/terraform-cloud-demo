# Find, fix, and prevent Terraform misconfigurations with Bridgecrew

In this tutorial,  you’ll learn how to scan infrastructure-as-code as part of your code review process. Using Terraform, GitHub Actions, and Bridgecrew, we’ll show you how to find, fix, and prevent cloud misconfigurations.
​
[Infrastructure-as-code](https://bridgecrew.io/blog/infrastructure-as-code-security-101/) (sometimes referred to as infrastructure code or abbreviated as IaC) is used to automate infrastructure deployment, scaling, and management using machine-readable configuration files.
​
# Using infrastructure-as-code
​
Before we dive in, let’s talk a bit about the use cases of infrastructure-as-code frameworks like Terraform. Terraform provides ready-made infrastructure-as-code modules to build and scale cloud-hosted web applications with just a few lines of code. As that benefit has become more evident for teams deploying to complex multi-cloud environments, Terraform adoption has skyrocketed.
​
Terraform has set the standard for usability and extendibility for infrastructure-as-code. You can find Terraform deployment templates—called modules—on GitHub and the open-source [Terraform Registry](https://registry.terraform.io/). By modifying just a few variables, you have ready-made networking, storage, or compute workloads ready for deployment.
​
# Securing infrastructure-as-code
​
The ease-of-use afforded by Terraform enables quite a lot of flexibility and speed when composing cloud infrastructure. It also unlocks the potential to bake in compliance and security earlier in the development lifecycle. Many Terraform modules come with security and compliance-related variables built-in, which, when configured in line with cloud security best practices, can harden and secure cloud infrastructure.
​
This is what a private S3 bucket with versioning enabled looks like:
​
```hcl
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
​
  bucket = "my-s3-bucket"
  acl    = "private"
​
  versioning = {
    enabled = true
  }
​
}
```
​
If variables are left undefined or are misconfigured, resources may be publicly exposed in your production cloud environment, potentially introducing risk. And as you utilize more and more modules, that risk grows exponentially—which is why we built Bridgecrew.
​
The [Bridgecrew platform](https://bridgecrew.io/platform) helps developers find misconfigurations in their infrastructure-as-code files and equips them with context and code to quickly implement fixes. The best way to utilize infrastructure-as-code scanning is by embedding it into your day-to-day code review processes as part of your build tests.
​
Let’s get started.
​
# Running Bridgecrew with CLI
For this tutorial, we’re going to start by deploying Bridgecrew locally.
​
## Installation
You can install Bridgecrew  to use with  your own project or  our “vulnerable-by-design" Terraform project, [TerraGoat](https://bridgecrew.io/blog/terragoat-open-source-infrastructure-code-security-training-project-terraform/).  In this tutorial, we will focus only on scanning standalone `.tf` files as they cover most of the common security and compliance testing scenarios.
​
> Note: You’re welcome to skip ahead to the “Integrating Bridgecrew with GitHub” section to integrate Bridgecrew directly with your GitHub repository containing Terraform files instead of running locally.
​
###  Using your own project
A simple search of your repositories for `.tf` files will immediately expose where Terraform files are stored. Install Bridgecrew and scan the folder or specific file:
    
    pip install bridgecrew
    
    # scan an input folder
    bridgecrew –d /user/tf
    
    # or a specific file
    bridgecrew –f /user/tf/example.tf
​
### Using TerraGoat
We built TerraGoat to help educate developers about some of the common Terraform misconfigurations and how to spot them with tools.  Clone the project and scan with Bridgecrew:
​
    # clone the project
    git clone git@github.com:bridgecrewio/terragoat.git
    
    cd terragoat
    
    # install Bridgecrew
    pip install bridgecrew
    
    # scan TerraGoat project
    bridgecrew -d terraform
​
# Reviewing Terraform scan results
Once you’ve scanned your file or folder, you’ll see output such as this:
                        
     _          _     _                                    
    | |__  _ __(_) __| | __ _  ___  ___ _ __ _____      __ 
    | '_ \| '__| |/ _` |/ _` |/ _ \/ __| '__/ _ \ \ /\ / / 
    | |_) | |  | | (_| | (_| |  __/ (__| | |  __/\ V  V /  
    |_.__/|_|  |_|\__,_|\__, |\___|\___|_|  \___| \_/\_/   
                         |___/                              
    
    by bridgecrew.io | version: 1.0.455
    
    terraform scan results:
    
    Passed checks: 2, Failed checks: 1, Skipped checks: 0
    
    Check: "Ensure all data stored in the S3 bucket is securely encrypted at rest"
    PASSED for resource: aws_s3_bucket.foo-bucket
    File: /example.tf:1-25
    
    Check: "Ensure the S3 bucket has access logging enabled"
    PASSED for resource: aws_s3_bucket.foo-bucket
    File: /example.tf:1-25
    
    Check: "S3 Bucket has an ACL defined which allows public access."
    FAILED for resource: aws_s3_bucket.foo-bucket
    File: /example.tf:1-25
    
    1 | resource "aws_s3_bucket" "foo-bucket" {
    2 | region = var.region
    3 | bucket = local.bucket_name
    4 | force_destroy = true
    5 |
    6 | tags = {
    7 | Name = "foo-${data.aws_caller_identity.current.account_id}"
    8 | }
    9 | versioning {
    10 | enabled = true
    11 | }
    12 | logging {
    13 | target_bucket = "${aws_s3_bucket.log_bucket.id}"
    14 | target_prefix = "log/"
    15 | }
    16 | server_side_encryption_configuration {
    17 | rule {
    18 | apply_server_side_encryption_by_default {
    19 | kms_master_key_id = "${aws_kms_key.mykey.arn}"
    20 | sse_algorithm = "aws:kms"
    21 | }
    22 | }
    23 | }
    24 | acl = "public-read"
    25 | }
​
Going through the simple example above, you’ll see that there are two passing checks and one failing check, “S3 Bucket has an ACL defined which allows public access.” The output has also printed the exact file and lines that triggered the check failure.
​
#  Bridgecrew account setup
Now that you know what to expect when scanning Terraform, let’s send your scan results to the Bridgecrew platform. [Sign up for a free Bridgecrew account](https://www.bridgecrew.cloud/login/signIn) using your email and password or with Google or GitHub auth.
​
![Image of Bridgecrew Getting Started](https://bridgecrew.io/wp-content/uploads/bridgecrew-screenshot-getting-started.png)
​
> Note: Bridgecrew is free to use for up to 100 resources and includes unlimited users and connected accounts.
​
# Integrating Bridgecrew  with GitHub
​
To automatically scan your repositories, integrate with [GitHub](https://docs.bridgecrew.io/docs/step-3-integrate-with-github) (you can also integrate with [Bitbucket](https://docs.bridgecrew.io/docs/integrate-with-bitbucket) and [GitLab](https://docs.bridgecrew.io/docs/integrate-with-gitlab)).
​
> Note: You need write or admin permissions to a repository to integrate Bridgecrew.
​
Go to the **Integrations** tab, click **GitHub**,  and **Authorize** Bridgecrew. 
![Bridgecrew GitHub integration](https://bridgecrew.io/wp-content/uploads/bridgecrew-screenshot-integration-source-control-github.png)
 
​
Next, connect your repositories containing Terraform files from the step before. Connecting to a GitHub repository will also kick off your first Terraform scan—in a few moments, you’ll see a list of identified misconfigurations and policy violations in the **Incidents** tab.
![Incidents in the Bridgecrew UI](https://bridgecrew.io/wp-content/uploads/bridgecrew-screenshot-incidents-terraform.png)
​
Identified misconfigurations get reported back to the Bridgecrew platform where they’re categorized, prioritized, and tracked over time.
​
![Bridgecrew security posture dashboard](https://bridgecrew.io/wp-content/uploads/bridgecrew-screenshot-dashboard.png)
​
Depending on the type of incident and resource, you can take various actions to fix or suppress identified issues.
​
# Fixing misconfigurations
By integrating with your GitHub repository, you’ve already given permission to implement pull request fixes for identified misconfigurations.
​
Simply select a resource to understand what specific attribute and argument led to its fail. For most resources, you can open a fix pull request with the code necessary to implement remediations for one or multiple resources.
​
![Implementing a fix PR](https://bridgecrew.io/wp-content/uploads/bridgecrew-screenshot-remediation-pull-request-terragoat.png)
​
Your repository will open in a new tab detailing the name of the pull request, details of the files changed and links to details and guidelines for the related Policy.
​
![<Fix PR in GitHub>](https://bridgecrew.io/wp-content/uploads/github-screenshot-fix-pull-request-terraform-rds.png)
​
By automating the finding and fixing of Terraform misconfigurations, Bridgecrew aims to help developers secure their cloud infrastructure earlier and save time doing it.
​
# Suppressing misconfigurations
By default, Bridgecrew will scan your entire repository and fail any build that contains at least one failed check. For the test to effectively flag the misconfigurations you care the most about, you'll need to identify which failing checks should and should not be part of the routine testing scope.
​
### Check-level suppression
We recommend that for your first run, use the soft-fail mechanism. With this setting enabled, the test will not fail builds but simply show a report of the failing tests. This mechanism gives developers time to get to know the new testing mechanism and to start adding skip annotations in their code.
​
### Resource-level suppression
To skip a check on a given Terraform definition block, apply the following comment pattern inside its scope:
​
    bridgecrew:skip=<check_id>:<suppression_comment> 
​
 
​
 
 -   `<check_id>` is one of the available check scanners (see AWS Policy Index)
    
 -   `<suppression_comment>` is an optional suppression reason to be included in the output
    
​
For example, this will skip the CKV_AWS_20 check on foo-bucket:
​
    resource  "aws_s3_bucket"  "foo-bucket"  {
      region  =  var.region  
        #bridgecrew:skip=CKV_AWS_20:The  bucket  is  a  public  static  content  host  
      bucket  =  local.bucket_name  
      force_destroy  =  true  
      acl  =  "public-read" 
    }
​
You can also use more [granular controls](https://docs.bridgecrew.io/docs/ingesting-scan-data#advanced-parameters) to further scope your build test workflow, [skip checks globally](https://docs.bridgecrew.io/docs/ingesting-scan-data#skip-check-globally), [run only specific checks](https://docs.bridgecrew.io/docs/ingesting-scan-data#run-only-specific-checks), or suppress resources directly from the Bridgecrew UI.
​
# Bonus! Setting up a GitHub Action
To automate your Terraform scans and run Bridgecrew as part of every code review, set up a [GitHub Action](https://docs.bridgecrew.io/docs/integrate-with-github-actions-v2) (you can also run Bridgecrew with [CircleCI](https://docs.bridgecrew.io/docs/integrate-with-circleci) and [Jenkins](https://docs.bridgecrew.io/docs/integrate-with-jenkins), or really any workflow).
​
GitHub Actions allow you to create automated workflows for testing and integrating your code into a web application.
​
> Note: You also need write or admin permissions to a repository to create and edit workflows.
​
You can find your workflows under the **Actions** tab on the top navigation bar in your GitHub repository. Workflows are stored in a workflows directory in your root directory. If this directory does not appear, create a new one. Add a new `.yaml` file for your Bridgecrew  workflow:
```
 - name: Run Bridgecrew 
    id: Bridgecrew
    uses: bridgecrewio/bridgecrew-action@master
    # This step uses the Bridgecrew Action: https://github.com/bridgecrewio/bridgecrew-action
    with:
      api-key: ${{ secrets.API_KEY }}
```

## Setup a GitHub Secret
Programmatic access keys are stored in GitHub Secrets. To define a new secret, go to **Settings** under your repository name. In the left sidebar, go to **Secrets** and select **Add a new Secret**. Name the secret BRIDGECREW_API_KEY and enter the Bridgecrew [API Token](https://docs.bridgecrew.io/docs/get-api-token). It’s located in the **Integrations** tab in the **Continuous Integration** section on the lefthand side.


That’s it! 


Every pull request will now automatically trigger a security test job to inspect the modified files and prevent misconfigurations from being deployed.
![enter image description here](https://bridgecrew.io/wp-content/uploads/github-screenshot-github-action-terragoat.png)




Your workflow is now ready to start continuously monitoring Terraform configuration changes. 


---
We hope this tutorial helped you get started with continuous infrastructure-as-code scanning and how to prevent the deployment of Terraform misconfigurations.

[Bridgecrew](https://bridgecrew.io/) is designed to provide continuous cloud infrastructure security for both deployed resources and code that provisions them. In addition to supporting Terraform, Bridgecrew connects to all the popular cloud providers—[AWS](https://docs.bridgecrew.io/docs/step-2-integrate-with-aws), [Azure](https://docs.bridgecrew.io/docs/integrate-with-microsoft-azure), and [Google Cloud](https://docs.bridgecrew.io/docs/integrate-with-google-cloud)—as well as [Kubernetes](https://docs.bridgecrew.io/docs/integrate-with-kubernetes), [CloudFormation](https://bridgecrew.io/blog/announcing-cloudformation-support-in-checkov/), and [ARM templates](https://bridgecrew.io/blog/scanning-azure-resource-manager-arm-templates-with-bridgecrew/). 

If you liked this post, follow us on [Twitter](https://twitter.com/bridgecrew) and subscribe to our [blog](https://bridgecrew.io/blog)! 🖖
​
