import boto3

PROFILE = "devops-admin"
REGION = "us-east-2"

session = boto3.Session(profile_name=PROFILE, region_name=REGION)
ec2 = session.client("ec2")

response = ec2.describe_security_groups()

print("Security groups allowing SSH from 0.0.0.0/0")
print("-" * 80)

found = False

for sg in response["SecurityGroups"]:
    for perm in sg.get("IpPermissions", []):
        from_port = perm.get("FromPort")
        to_port = perm.get("ToPort")
        protocol = perm.get("IpProtocol")

        if protocol == "tcp" and from_port == 22 and to_port == 22:
            for ip_range in perm.get("IpRanges", []):
                if ip_range.get("CidrIp") == "0.0.0.0/0":
                    found = True
                    print(f"{sg['GroupId']} | {sg['GroupName']} | VPC={sg.get('VpcId', '-')}")
                    break

if not found:
    print("No security groups found with public SSH.")
