# terraform-examples

#### Commands
To run the terraform script you need to execute the following command:

`terraform apply`

This will create an execution plan that will tell you what resources will be created. It will than prompt you for a y/n to confirm whether you want to apply the execution plan.

To destroy you VPC you must run the following command:

`terraform destroy`

If you would like to see a list of the outputs as a result of running the script you can use the following command:

`terraform output`

If you want to see a human readable output of the terraform state file you can run the following:

`terraform show`

#### SSH Connection
In order to connect to the boxes in the private subnet you must first ssh onto the public subnet boxes. To do this you must use ssh agent forwarding. There are a few steps to doing this.

Firstly you must add the agencies to the ssh-agent. To check which identities are already you must run the following command:

`ssh-add -l`

then add your key with the following command

`ssh-add ~/.ssh/yourkey.pem`

to remove all your identities you can run the following command

`ssh-add -D`

The next thing you need to do is connect using agent forwarding. This can be done with the following:

`ssh -A username@hostname`