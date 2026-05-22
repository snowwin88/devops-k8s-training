import boto3

PROFILE = "devops-admin"
REGION = "us-east-2"

session = boto3.Session(profile_name=PROFILE, region_name=REGION)
ec2 = session.client("ec2")

response = ec2.describe_instances()

print(f"EC2 Inventory - region={REGION}, profile={PROFILE}")
print("-" * 100)

found = False

for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        found = True
        instance_id = instance["InstanceId"]
        state = instance["State"]["Name"]
        instance_type = instance["InstanceType"]
        public_ip = instance.get("PublicIpAddress", "-")
        private_ip = instance.get("PrivateIpAddress", "-")
        subnet_id = instance.get("SubnetId", "-")
        vpc_id = instance.get("VpcId", "-")

        name = "-"
        for tag in instance.get("Tags", []):
            if tag["Key"] == "Name":
                name = tag["Value"]

        print(
            f"{instance_id} | {state} | {instance_type} | "
            f"public={public_ip} | private={private_ip} | "
            f"subnet={subnet_id} | vpc={vpc_id} | name={name}"
        )

if not found:
    print("No EC2 instances found.")
